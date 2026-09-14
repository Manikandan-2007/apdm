import React from 'react';
import { MessageSquare, BookOpen, Mic, History, Sliders } from 'lucide-react';
import { useApp } from '../context/AppContext';

interface NavigationProps {
  currentTab: number;
  onTabChange: (index: number) => void;
  onOpenVoice: () => void;
}

export const Navigation: React.FC<NavigationProps> = ({
  currentTab,
  onTabChange,
  onOpenVoice,
}) => {
  const { palette } = useApp();

  const tabs = [
    { label: 'Chat', icon: MessageSquare, id: 'nav-chat' },
    { label: 'Memories', icon: BookOpen, id: 'nav-memories' },
    { label: 'Voice', icon: Mic, isVoiceAction: true, id: 'nav-voice' },
    { label: 'History', icon: History, id: 'nav-history' },
    { label: 'Settings', icon: Sliders, id: 'nav-settings' },
  ];

  return (
    <nav
      id="bottom-navigation-bar"
      className="shrink-0 border-t transition-colors duration-200 z-20"
      style={{
        backgroundColor: palette.surface,
        borderColor: palette.border,
      }}
    >
      <div className="max-w-md mx-auto flex items-center justify-around px-2 py-1.5">
        {tabs.map((tab, idx) => {
          const Icon = tab.icon;
          const isSelected = currentTab === idx;

          if (tab.isVoiceAction) {
            return (
              <button
                key={tab.id}
                id={tab.id}
                type="button"
                onClick={onOpenVoice}
                aria-label="Open Voice Companion"
                className="relative -top-3 w-13 h-13 rounded-full flex items-center justify-center shadow-xl transition-all duration-300 hover:scale-105 active:scale-95 border-2"
                style={{
                  background: `linear-gradient(135deg, ${palette.primaryLight || palette.primary}, ${palette.primary})`,
                  borderColor: palette.surface,
                  boxShadow: `0 4px 20px ${palette.accentGlow}`,
                }}
              >
                <Icon className="w-6 h-6 text-white" />
              </button>
            );
          }

          return (
            <button
              key={tab.id}
              id={tab.id}
              type="button"
              onClick={() => onTabChange(idx)}
              className="flex flex-col items-center justify-center py-1 px-3 rounded-xl transition-all active:scale-95"
              style={{
                color: isSelected ? palette.primary : palette.textSecondary,
              }}
            >
              <Icon className="w-5 h-5 mb-0.5" />
              <span className="text-[10px] font-semibold tracking-wide">
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
