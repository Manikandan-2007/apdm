import { VoiceState, AppLanguage } from '../types';

type VoiceStateListener = (state: VoiceState) => void;
type TranscriptListener = (transcript: string) => void;
type SoundLevelListener = (level: number) => void;
type SpeakingListener = (isSpeaking: boolean) => void;

class SoundEffectsEngine {
  private ctx: AudioContext | null = null;

  public unlock(): AudioContext | null {
    if (typeof window === 'undefined') return null;
    try {
      if (!this.ctx) {
        const AudioContextClass =
          window.AudioContext || (window as any).webkitAudioContext;
        if (AudioContextClass) {
          this.ctx = new AudioContextClass();
        }
      }
      if (this.ctx && this.ctx.state === 'suspended') {
        this.ctx.resume();
      }
      return this.ctx;
    } catch (err) {
      console.warn('[APDM Sound] Could not unlock AudioContext:', err);
      return null;
    }
  }

  public playTone(
    freq: number,
    duration: number,
    startOffset = 0,
    type: OscillatorType = 'sine',
    peakGain = 0.2
  ): void {
    const ctx = this.unlock();
    if (!ctx) return;
    try {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = type;
      osc.frequency.setValueAtTime(freq, ctx.currentTime + startOffset);

      const startTime = ctx.currentTime + startOffset;
      gain.gain.setValueAtTime(0.0001, startTime);
      gain.gain.linearRampToValueAtTime(peakGain, startTime + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, startTime + duration);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start(startTime);
      osc.stop(startTime + duration);
    } catch (err) {
      console.warn('[APDM Sound] PlayTone error:', err);
    }
  }

  public playChime(type: 'send' | 'receive' | 'test' | 'listen'): void {
    const ctx = this.unlock();
    if (!ctx) return;

    if (type === 'send') {
      // Crisp, warm sending chime: C5 -> G5
      this.playTone(523.25, 0.12, 0, 'sine', 0.16);
      this.playTone(783.99, 0.18, 0.07, 'sine', 0.2);
    } else if (type === 'receive') {
      // Gentle welcoming chime: F5 -> A5 -> C6
      this.playTone(698.46, 0.14, 0, 'sine', 0.18);
      this.playTone(880.0, 0.16, 0.08, 'sine', 0.2);
      this.playTone(1046.5, 0.35, 0.16, 'sine', 0.24);
    } else if (type === 'test') {
      // Full warm 4-chord bell tone: C5 -> E5 -> G5 -> C6
      this.playTone(523.25, 0.25, 0, 'triangle', 0.22);
      this.playTone(659.25, 0.28, 0.1, 'triangle', 0.22);
      this.playTone(783.99, 0.32, 0.2, 'sine', 0.25);
      this.playTone(1046.5, 0.6, 0.3, 'sine', 0.3);
    } else if (type === 'listen') {
      // Soft audio start indicator
      this.playTone(587.33, 0.1, 0, 'sine', 0.14);
      this.playTone(880.0, 0.18, 0.06, 'sine', 0.18);
    }
  }
}

class SpeechService {
  private state: VoiceState = 'ready';
  private liveTranscript = '';
  private isSpeaking = false;
  private speechError = false;
  private hasPrimedSpeech = false;
  private cachedVoices: SpeechSynthesisVoice[] = [];
  private recognition: any = null;
  private soundLevelInterval: any = null;
  private chromeKeepAliveInterval: any = null;
  private currentUtterance: SpeechSynthesisUtterance | null = null;
  private soundEffects = new SoundEffectsEngine();
  private currentRecognitionLang = 'ta-IN';
  private accumulatedTranscript = '';
  private isExplicitlyStopping = false;

  private stateListeners: Set<VoiceStateListener> = new Set();
  private transcriptListeners: Set<TranscriptListener> = new Set();
  private soundLevelListeners: Set<SoundLevelListener> = new Set();
  private speakingListeners: Set<SpeakingListener> = new Set();
  private speechErrorListeners: Set<(hasError: boolean) => void> = new Set();

  constructor() {
    if (typeof window !== 'undefined') {
      try {
        if (window.speechSynthesis) {
          const updateVoices = () => {
            try {
              const v = window.speechSynthesis.getVoices();
              if (v && v.length > 0) {
                this.cachedVoices = v;
              }
            } catch (e) {
              // ignore
            }
          };

          updateVoices();

          if ('onvoiceschanged' in window.speechSynthesis) {
            window.speechSynthesis.onvoiceschanged = updateVoices;
          }
          if (typeof window.speechSynthesis.addEventListener === 'function') {
            window.speechSynthesis.addEventListener('voiceschanged', updateVoices);
          }
        }
      } catch (e) {
        console.warn('[APDM] SpeechSynthesis init note:', e);
      }
    }
  }

  public unlockAudio() {
    this.soundEffects.unlock();
    if (typeof window !== 'undefined' && window.speechSynthesis) {
      try {
        if (window.speechSynthesis.paused) {
          window.speechSynthesis.resume();
        }
        // Prime speech engine during user interaction to satisfy mobile autoplay policies
        if (!this.hasPrimedSpeech) {
          const dummy = new SpeechSynthesisUtterance(' ');
          dummy.volume = 0.001;
          dummy.rate = 10;
          dummy.onend = () => {
            // primed
          };
          dummy.onerror = () => {
            // ignore
          };
          window.speechSynthesis.speak(dummy);
          this.hasPrimedSpeech = true;
        }
      } catch (e) {
        // ignore
      }
    }
  }

  public playChime(type: 'send' | 'receive' | 'test' | 'listen') {
    this.soundEffects.playChime(type);
  }

  public getIsSpeaking(): boolean {
    return this.isSpeaking;
  }

  public setRecognitionLanguage(langCode: string) {
    this.currentRecognitionLang = langCode;
    if (this.recognition) {
      try {
        this.recognition.lang = langCode;
      } catch (e) {
        // ignore
      }
    }
    console.log('[STT] language:', langCode);
  }

  public getRecognitionLanguage(): string {
    return this.currentRecognitionLang;
  }

  private ensureRecognition(): any {
    if (typeof window === 'undefined') return null;
    if (this.recognition) return this.recognition;

    try {
      const SpeechRecognition =
        (window as any).SpeechRecognition ||
        (window as any).webkitSpeechRecognition;

      if (!SpeechRecognition) return null;

      const rec = new SpeechRecognition();
      rec.continuous = true;
      rec.interimResults = true;
      rec.lang = this.currentRecognitionLang;

      rec.onstart = () => {
        this.setState('listening');
        this.startSoundLevelSimulation();
        console.log('[STT] language:', rec.lang || this.currentRecognitionLang);
      };

      rec.onresult = (event: any) => {
        let interim = '';
        let final = '';
        for (let i = 0; i < event.results.length; ++i) {
          const res = event.results[i];
          if (res.isFinal) {
            final += res[0].transcript + ' ';
          } else {
            interim += res[0].transcript;
          }
        }
        const current = (this.accumulatedTranscript + final + interim).trim();
        this.setTranscript(current);
        console.log('[STT] transcript:', current);
      };

      rec.onerror = (event: any) => {
        console.warn('[STT] error:', event.error);
        if (event.error === 'not-allowed') {
          console.warn('[STT] Microphone access was denied.');
          this.isExplicitlyStopping = true;
          this.stopListening();
        }
      };

      rec.onend = () => {
        if (!this.isExplicitlyStopping && this.state === 'listening') {
          try {
            rec.lang = this.currentRecognitionLang;
            rec.start();
            return;
          } catch (err) {
            // Ignore restart collision if already active
          }
        }

        this.stopSoundLevelSimulation();
        if (this.state === 'listening') {
          this.setState('ready');
        }
      };

      this.recognition = rec;
      return rec;
    } catch (err) {
      console.warn('[APDM] SpeechRecognition could not be initialized:', err);
      return null;
    }
  }

  public subscribeState(listener: VoiceStateListener): () => void {
    this.stateListeners.add(listener);
    listener(this.state);
    return () => this.stateListeners.delete(listener);
  }

  public subscribeTranscript(listener: TranscriptListener): () => void {
    this.transcriptListeners.add(listener);
    listener(this.liveTranscript);
    return () => this.transcriptListeners.delete(listener);
  }

  public subscribeSoundLevel(listener: SoundLevelListener): () => void {
    this.soundLevelListeners.add(listener);
    return () => this.soundLevelListeners.delete(listener);
  }

  public subscribeSpeaking(listener: SpeakingListener): () => void {
    this.speakingListeners.add(listener);
    listener(this.isSpeaking);
    return () => this.speakingListeners.delete(listener);
  }

  public subscribeSpeechError(listener: (hasError: boolean) => void): () => void {
    this.speechErrorListeners.add(listener);
    listener(this.speechError);
    return () => this.speechErrorListeners.delete(listener);
  }

  public getSpeechError(): boolean {
    return this.speechError;
  }

  public setState(state: VoiceState) {
    this.state = state;
    this.stateListeners.forEach((l) => l(state));
  }

  public setTranscript(transcript: string) {
    this.liveTranscript = transcript;
    this.transcriptListeners.forEach((l) => l(transcript));
  }

  public async startListening(): Promise<boolean> {
    this.stopSpeaking();
    this.unlockAudio();
    this.liveTranscript = '';
    this.setTranscript('');
    this.accumulatedTranscript = '';
    this.isExplicitlyStopping = false;

    const rec = this.ensureRecognition();
    if (rec) {
      try {
        rec.lang = this.currentRecognitionLang;
        console.log('[STT] language:', rec.lang);
        rec.start();
        return true;
      } catch (err) {
        console.log('[STT] Recognition start note:', err);
      }
    }

    // Fallback: start state directly with simulated audio pulse
    this.setState('listening');
    this.startSoundLevelSimulation();
    return true;
  }

  public async stopListening(): Promise<string> {
    this.isExplicitlyStopping = true;
    this.stopSoundLevelSimulation();
    if (this.recognition) {
      try {
        this.recognition.stop();
      } catch (err) {
        // ignore
      }
    }
    const result = this.liveTranscript.trim();
    console.log('[STT] transcript:', result);
    return result;
  }

  public cancelListening() {
    this.isExplicitlyStopping = true;
    this.stopSoundLevelSimulation();
    if (this.recognition) {
      try {
        this.recognition.abort();
      } catch (err) {
        // ignore
      }
    }
    this.liveTranscript = '';
    this.setTranscript('');
    this.accumulatedTranscript = '';
    this.setState('ready');
  }

  private loadVoices(): SpeechSynthesisVoice[] {
    if (typeof window === 'undefined' || !window.speechSynthesis) return [];
    try {
      const v = window.speechSynthesis.getVoices();
      if (v && v.length > 0) {
        this.cachedVoices = v;
      }
      return this.cachedVoices;
    } catch (e) {
      return this.cachedVoices;
    }
  }

  private async getVoicesAsync(): Promise<SpeechSynthesisVoice[]> {
    if (typeof window === 'undefined' || !window.speechSynthesis) return [];

    const immediate = this.loadVoices();
    if (immediate.length > 0) return immediate;

    return new Promise((resolve) => {
      let resolved = false;
      const finish = () => {
        if (!resolved) {
          resolved = true;
          cleanup();
          resolve(this.loadVoices());
        }
      };

      const handler = () => finish();

      const cleanup = () => {
        try {
          window.speechSynthesis.removeEventListener?.('voiceschanged', handler);
        } catch (e) {}
      };

      try {
        window.speechSynthesis.addEventListener?.('voiceschanged', handler);
        const prevHandler = window.speechSynthesis.onvoiceschanged;
        window.speechSynthesis.onvoiceschanged = (e) => {
          if (prevHandler) {
            try {
              prevHandler.call(window.speechSynthesis, e);
            } catch (err) {}
          }
          finish();
        };
      } catch (e) {}

      setTimeout(finish, 250);
    });
  }

  private selectVoiceAndLang(
    voices: SpeechSynthesisVoice[],
    language?: AppLanguage,
    text: string = ''
  ): { voice: SpeechSynthesisVoice | null; lang: string } {
    const hasTamilScript = /[\u0B80-\u0BFF]/.test(text);
    const isTamil = hasTamilScript || language === 'tamil';
    const isTanglish = !hasTamilScript && language === 'tanglish';

    if (!voices || voices.length === 0) {
      return {
        voice: null,
        lang: isTamil ? 'ta-IN' : isTanglish ? 'en-IN' : 'en-IN',
      };
    }

    if (isTamil) {
      // 1. Primary: Native Tamil voice (ta-IN, ta_IN, ta-LK, ta-SG, or name containing Tamil)
      const tamilVoice = voices.find(
        (v) =>
          v.lang.toLowerCase().replace('_', '-').startsWith('ta') ||
          v.name.toLowerCase().includes('tamil') ||
          v.name.includes('தமிழ்')
      );
      if (tamilVoice) {
        return { voice: tamilVoice, lang: tamilVoice.lang || 'ta-IN' };
      }

      // 2. Fallback: Indian English or Indic voice capable of pronouncing Indian phonetics
      const indicVoice = voices.find(
        (v) =>
          v.lang.toLowerCase().replace('_', '-').includes('en-in') ||
          v.name.toLowerCase().includes('india') ||
          v.name.toLowerCase().includes('rishi') ||
          v.name.toLowerCase().includes('veena') ||
          v.name.toLowerCase().includes('neerja') ||
          v.name.toLowerCase().includes('prabhat')
      );
      if (indicVoice) {
        return { voice: indicVoice, lang: indicVoice.lang || 'en-IN' };
      }

      // 3. Fallback: System default or first available voice (set lang to ta-IN so Chrome/OS routes correctly)
      const defaultOrFirst =
        voices.find((v) => v.default) ||
        voices.find((v) => v.lang.toLowerCase().startsWith('en')) ||
        voices[0] ||
        null;
      return { voice: defaultOrFirst, lang: defaultOrFirst?.lang || 'ta-IN' };
    }

    if (isTanglish) {
      // Tanglish: colloquial Tamil written in Latin alphabet
      // 1. Best Indian voice (en-IN or ta-IN) that naturally pronounces Indian phonetics
      const indianVoice =
        voices.find(
          (v) =>
            v.lang.toLowerCase().replace('_', '-').includes('en-in') ||
            v.name.toLowerCase().includes('india') ||
            v.name.toLowerCase().includes('rishi') ||
            v.name.toLowerCase().includes('veena') ||
            v.name.toLowerCase().includes('neerja') ||
            v.name.toLowerCase().includes('prabhat')
        ) ||
        voices.find(
          (v) =>
            v.lang.toLowerCase().replace('_', '-').startsWith('ta') ||
            v.name.toLowerCase().includes('tamil')
        );
      if (indianVoice) {
        return { voice: indianVoice, lang: indianVoice.lang || 'en-IN' };
      }

      // 2. Fallback: Standard English voice
      const englishVoice =
        voices.find((v) => v.lang.toLowerCase().startsWith('en')) ||
        voices.find((v) => v.default) ||
        voices[0] ||
        null;
      return { voice: englishVoice, lang: englishVoice?.lang || 'en-IN' };
    }

    // English
    // 1. Preferred Indian English voice
    const enInVoice = voices.find(
      (v) =>
        v.lang.toLowerCase().replace('_', '-').includes('en-in') ||
        v.name.toLowerCase().includes('india')
    );
    if (enInVoice) {
      return { voice: enInVoice, lang: enInVoice.lang || 'en-IN' };
    }

    // 2. Fallback: en-US, en-GB, or any English voice
    const enUsVoice =
      voices.find(
        (v) =>
          v.lang.toLowerCase().replace('_', '-').startsWith('en-us') ||
          v.lang.toLowerCase().startsWith('en')
      ) ||
      voices.find((v) => v.default) ||
      voices[0] ||
      null;
    return { voice: enUsVoice, lang: enUsVoice?.lang || 'en-US' };
  }

  public async speak(text: string, language?: AppLanguage): Promise<void> {
    if (typeof window === 'undefined') return;

    if (!window.speechSynthesis) {
      console.warn('[TTS] Speech error: window.speechSynthesis is not supported on this device/browser');
      this.speechError = true;
      this.speechErrorListeners.forEach((l) => l(true));
      return;
    }

    // Clean emojis, markdown, and punctuation quirks for smooth speech
    const cleaned = text
      .replace(/[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu, '')
      .replace(/[*#_~`>]/g, '')
      .replace(/https?:\/\/\S+/g, '')
      .trim();

    if (!cleaned) {
      return;
    }

    // Cancel any ongoing speech first to clear the audio channel
    try {
      window.speechSynthesis.cancel();
    } catch (e) {}

    // Wait 60ms for browser speech daemon IPC to cleanly process cancellation
    // without inadvertently cancelling the newly created utterance
    await new Promise((r) => setTimeout(r, 60));

    // Resume speech synthesis if paused
    try {
      if (window.speechSynthesis.paused) {
        window.speechSynthesis.resume();
      }
    } catch (e) {}

    const voices = await this.getVoicesAsync();
    const { voice: selectedVoice, lang: selectedLang } = this.selectVoiceAndLang(
      voices,
      language,
      cleaned
    );

    // Instrument required logging
    console.log('[TTS] speak() called');
    console.log('[TTS] Text:', cleaned);
    console.log('[TTS] Language:', selectedLang);
    console.log('[TTS] Selected voice:', selectedVoice?.name || selectedVoice?.lang || 'system default');

    // Split text into natural sentence chunks to avoid browser synthesis buffer stalls
    const rawChunks = cleaned.match(/[^.!?\n]+[.!?\n]*/g) || [cleaned];
    const chunks = rawChunks
      .map((c) => c.trim())
      .filter((c) => c.length > 0);

    if (chunks.length === 0) return;

    this.speechError = false;
    this.speechErrorListeners.forEach((l) => l(false));
    this.isSpeaking = true;
    this.speakingListeners.forEach((l) => l(true));
    this.setState('speaking');
    this.startSoundLevelSimulation();

    // Chrome keep-alive: Chrome pauses speech synthesis after ~15 seconds without periodic resume()
    if (this.chromeKeepAliveInterval) clearInterval(this.chromeKeepAliveInterval);
    this.chromeKeepAliveInterval = setInterval(() => {
      if (typeof window !== 'undefined' && window.speechSynthesis) {
        window.speechSynthesis.resume();
      }
    }, 1500);

    try {
      for (const chunk of chunks) {
        if (!this.isSpeaking) break; // cancelled by user

        await new Promise<void>((resolve) => {
          const utterance = new SpeechSynthesisUtterance(chunk);
          // Retain global reference to avoid Chromium V8 garbage collection bug
          (window as any).__activeUtterance = utterance;
          this.currentUtterance = utterance;

          utterance.rate = 0.95;
          utterance.pitch = 1.0;
          utterance.volume = 1.0;
          utterance.lang = selectedLang;
          if (selectedVoice) {
            utterance.voice = selectedVoice;
          }

          let resolved = false;
          const finish = () => {
            if (!resolved) {
              resolved = true;
              (window as any).__activeUtterance = null;
              this.currentUtterance = null;
              resolve();
            }
          };

          utterance.onstart = () => {
            console.log('[TTS] Speech started');
          };

          utterance.onend = () => {
            console.log('[TTS] Speech ended');
            finish();
          };

          utterance.onerror = (e) => {
            if (e.error === 'canceled' || e.error === 'interrupted') {
              console.log('[TTS] Speech ended (interrupted/canceled)');
            } else {
              console.warn('[TTS] Speech error:', e.error || e);
              this.speechError = true;
              this.speechErrorListeners.forEach((l) => l(true));
            }
            finish();
          };

          // Watchdog timer so speech never hangs if browser fails to trigger onend
          const timeoutMs = Math.max(7000, chunk.length * 220);
          const timer = setTimeout(() => {
            if (!resolved) {
              console.warn('[TTS] Utterance timeout watchdog triggered');
              finish();
            }
          }, timeoutMs);

          try {
            window.speechSynthesis.speak(utterance);
            // If browser is in paused state, resume immediately
            if (window.speechSynthesis.paused) {
              window.speechSynthesis.resume();
            }
          } catch (speakErr) {
            clearTimeout(timer);
            console.error('[TTS] Speech error:', speakErr);
            this.speechError = true;
            this.speechErrorListeners.forEach((l) => l(true));
            finish();
          }
        });
      }
    } finally {
      if (this.chromeKeepAliveInterval) {
        clearInterval(this.chromeKeepAliveInterval);
        this.chromeKeepAliveInterval = null;
      }
      (window as any).__activeUtterance = null;
      this.currentUtterance = null;
      this.isSpeaking = false;
      this.stopSoundLevelSimulation();
      this.speakingListeners.forEach((l) => l(false));
      this.setState('ready');
    }
  }

  public async testSound(customPrompt?: string): Promise<void> {
    this.stopSpeaking();
    this.unlockAudio();

    // Play test chime first so user gets instant audible feedback
    this.soundEffects.playChime('test');

    const sampleText =
      customPrompt ||
      'வணக்கம் கண்ணா! நான் அப்பா பேசுறேன். என்னோட குரல் தெளிவா கேட்குதா? (Vanakkam kanna! Naan Appa pesuren. Audio is working loud and clear!)';

    // Wait slightly for the chime to ring out before speaking
    await new Promise((r) => setTimeout(r, 450));
    await this.speak(sampleText);
  }

  public stopSpeaking() {
    if (this.chromeKeepAliveInterval) {
      clearInterval(this.chromeKeepAliveInterval);
      this.chromeKeepAliveInterval = null;
    }
    this.isSpeaking = false;
    if (typeof window !== 'undefined' && window.speechSynthesis) {
      try {
        window.speechSynthesis.cancel();
      } catch (e) {
        // ignore
      }
    }
    (window as any).__activeUtterance = null;
    this.currentUtterance = null;
    this.stopSoundLevelSimulation();
    this.speakingListeners.forEach((l) => l(false));
    if (this.state === 'speaking') {
      this.setState('ready');
    }
  }

  private startSoundLevelSimulation() {
    this.stopSoundLevelSimulation();
    this.soundLevelInterval = setInterval(() => {
      // Gentle fluctuating wave for voice orb and audio activity
      const level = 0.25 + Math.random() * 0.65;
      this.soundLevelListeners.forEach((l) => l(level));
    }, 120);
  }

  private stopSoundLevelSimulation() {
    if (this.soundLevelInterval) {
      clearInterval(this.soundLevelInterval);
      this.soundLevelInterval = null;
    }
    this.soundLevelListeners.forEach((l) => l(0.2));
  }
}

export const speechService = new SpeechService();

