import React from 'react';
import { motion } from 'motion/react';
import { Mic, Volume2, Sparkles, Square } from 'lucide-react';
import { VoiceState } from '../types';
import { VOICE_STATE_COLORS } from '../constants/theme';

interface VoiceOrbProps {
  state: VoiceState;
  onTap?: () => void;
  size?: number;
  soundLevel?: number;
}

export const VoiceOrbVisualizer: React.FC<VoiceOrbProps> = ({
  state,
  onTap,
  size = 200,
  soundLevel = 0.2,
}) => {
  const currentColor = VOICE_STATE_COLORS[state];

  // Dynamic animation settings based on state
  const getPulseDuration = () => {
    switch (state) {
      case 'listening':
        return 0.8;
      case 'processing':
        return 1.4;
      case 'speaking':
        return 1.1;
      case 'ready':
      default:
        return 2.4;
    }
  };

  const getScaleMultiplier = () => {
    if (state === 'listening') {
      return 1 + Math.min(soundLevel * 0.35, 0.4);
    }
    if (state === 'speaking') {
      return 1.12;
    }
    return 1.05;
  };

  const getLabel = () => {
    switch (state) {
      case 'listening':
        return 'Listening...';
      case 'processing':
        return 'Reflecting on memories...';
      case 'speaking':
        return 'Companion speaking...';
      case 'ready':
      default:
        return 'Tap to speak with APDM';
    }
  };

  const renderIcon = () => {
    switch (state) {
      case 'speaking':
        return <Volume2 className="w-10 h-10 text-white animate-pulse" />;
      case 'processing':
        return <Sparkles className="w-10 h-10 text-white animate-spin" />;
      case 'listening':
        return <Square className="w-8 h-8 text-white fill-white" />;
      case 'ready':
      default:
        return <Mic className="w-10 h-10 text-white" />;
    }
  };

  return (
    <div className="flex flex-col items-center justify-center select-none">
      <div
        id="voice-orb-container"
        className="relative flex items-center justify-center cursor-pointer touch-manipulation"
        style={{ width: size, height: size }}
        onClick={onTap}
      >
        {/* Outer Halo Glow */}
        <motion.div
          animate={{
            scale: [1, getScaleMultiplier() * 1.15, 1],
            opacity: state === 'listening' ? [0.4, 0.7, 0.4] : [0.2, 0.4, 0.2],
          }}
          transition={{
            duration: getPulseDuration(),
            repeat: Infinity,
            ease: 'easeInOut',
          }}
          className="absolute inset-0 rounded-full blur-2xl"
          style={{ backgroundColor: currentColor }}
        />

        {/* Outer Concentric Wave Ring */}
        <motion.div
          animate={{
            scale: [0.95, 1.25, 0.95],
            opacity: [0.3, 0.7, 0.3],
            rotate: 360,
          }}
          transition={{
            scale: {
              duration: getPulseDuration() * 1.2,
              repeat: Infinity,
              ease: 'easeInOut',
            },
            rotate: {
              duration: 8,
              repeat: Infinity,
              ease: 'linear',
            },
          }}
          className="absolute inset-2 rounded-full border-2 border-dashed"
          style={{ borderColor: currentColor }}
        />

        {/* Secondary Harmonic Wave Ring */}
        <motion.div
          animate={{
            scale: [1.1, 0.92, 1.1],
            opacity: [0.25, 0.6, 0.25],
            rotate: -360,
          }}
          transition={{
            scale: {
              duration: getPulseDuration() * 0.9,
              repeat: Infinity,
              ease: 'easeInOut',
            },
            rotate: {
              duration: 12,
              repeat: Infinity,
              ease: 'linear',
            },
          }}
          className="absolute inset-4 rounded-full border border-dotted"
          style={{ borderColor: currentColor }}
        />

        {/* Central Luminous Core Orb */}
        <motion.div
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.94 }}
          animate={{
            scale: [1, getScaleMultiplier(), 1],
            boxShadow: [
              `0 0 20px ${currentColor}80`,
              `0 0 50px ${currentColor}bb`,
              `0 0 20px ${currentColor}80`,
            ],
          }}
          transition={{
            duration: getPulseDuration(),
            repeat: Infinity,
            ease: 'easeInOut',
          }}
          className="relative z-10 flex items-center justify-center rounded-full shadow-2xl transition-colors duration-500"
          style={{
            width: size * 0.65,
            height: size * 0.65,
            background: `radial-gradient(circle at 35% 35%, ${currentColor}ee, ${currentColor}aa 60%, #101018 100%)`,
            border: `2px solid ${currentColor}`,
          }}
        >
          {renderIcon()}
        </motion.div>
      </div>

      {/* State Status Text */}
      <motion.p
        key={state}
        initial={{ opacity: 0, y: 4 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-5 text-sm font-medium tracking-wide"
        style={{ color: currentColor }}
      >
        {getLabel()}
      </motion.p>
    </div>
  );
};
