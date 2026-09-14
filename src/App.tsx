import React, { useState } from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { Navigation } from './components/Navigation';
import { ChatScreen } from './components/ChatScreen';
import { MemoriesScreen } from './components/MemoriesScreen';
import { HistoryScreen } from './components/HistoryScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { VoiceConversationScreen } from './components/VoiceConversationScreen';

const MainAppLayout: React.FC = () => {
  const { palette, sendMessage } = useApp();
  const [currentTab, setCurrentTab] = useState<number>(0);
  const [isVoiceOpen, setIsVoiceOpen] = useState<boolean>(false);

  const handleReflectInChat = (prompt: string) => {
    setCurrentTab(0);
    if (prompt) {
      sendMessage(prompt);
    }
  };

  return (
    <div
      id="app-root-container"
      className="flex flex-col h-screen w-screen overflow-hidden antialiased"
      style={{
        backgroundColor: palette.background,
        color: palette.textPrimary,
      }}
    >
      {/* Primary Screen Area */}
      <main className="flex-1 overflow-hidden relative">
        {currentTab === 1 ? (
          <MemoriesScreen onReflectInChat={handleReflectInChat} />
        ) : currentTab === 3 ? (
          <HistoryScreen onSwitchToChat={() => setCurrentTab(0)} />
        ) : currentTab === 4 ? (
          <SettingsScreen />
        ) : (
          <ChatScreen
            onNavigateToMemories={() => setCurrentTab(1)}
            onNavigateToVoice={() => setIsVoiceOpen(true)}
          />
        )}

        {/* Fullscreen Voice Companion Overlay */}
        {isVoiceOpen && (
          <VoiceConversationScreen
            onClose={() => setIsVoiceOpen(false)}
            onNavigateToChat={() => {
              setIsVoiceOpen(false);
              setCurrentTab(0);
            }}
          />
        )}
      </main>

      {/* Persistent Bottom Navigation */}
      <Navigation
        currentTab={currentTab}
        onTabChange={(tabIdx) => setCurrentTab(tabIdx)}
        onOpenVoice={() => setIsVoiceOpen(true)}
      />
    </div>
  );
};

export const App: React.FC = () => {
  return (
    <AppProvider>
      <MainAppLayout />
    </AppProvider>
  );
};

export default App;
