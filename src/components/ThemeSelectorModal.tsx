import React from 'react';
import { X, Check, Palette, Moon, Sun } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { THEME_PALETTES } from '../constants/theme';
import { ThemePresetId } from '../types';

interface ThemeSelectorModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const ThemeSelectorModal: React.FC<ThemeSelectorModalProps> = ({
  isOpen,
  onClose,
}) => {
  const { themePreset, setThemePreset, palette, isDarkMode, setIsDarkMode } = useApp();

  if (!isOpen) return null;

  const presets = Object.values(THEME_PALETTES);

  return (
    <div
      id="theme-selector-modal"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/75 backdrop-blur-sm animate-fade-in"
    >
      <div
        className="w-full max-w-lg max-h-[85vh] flex flex-col rounded-t-3xl sm:rounded-3xl shadow-2xl border overflow-hidden"
        style={{
          backgroundColor: palette.surface,
          borderColor: palette.border,
        }}
      >
        {/* Header */}
        <div
          className="p-5 pb-3 border-b flex items-center justify-between"
          style={{ borderColor: palette.border }}
        >
          <div className="flex items-center gap-2">
            <Palette className="w-5 h-5" style={{ color: palette.primary }} />
            <div>
              <h2
                className="text-lg font-bold tracking-tight"
                style={{ color: palette.textPrimary }}
              >
                APDM Theme & Ambience
              </h2>
              <p className="text-xs" style={{ color: palette.textSecondary }}>
                Vannangal matrum amayum ninaivugal
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-full hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
            style={{ color: palette.textSecondary }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          {/* Dark / Light Mode Toggle */}
          <div
            className="p-3.5 rounded-2xl border flex items-center justify-between"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center gap-2.5">
              {isDarkMode ? (
                <Moon className="w-4 h-4" style={{ color: palette.primary }} />
              ) : (
                <Sun className="w-4 h-4" style={{ color: palette.primary }} />
              )}
              <div>
                <div className="text-xs font-semibold" style={{ color: palette.textPrimary }}>
                  {isDarkMode ? 'Dark Ambience Mode' : 'Daylight Linen Mode'}
                </div>
                <div className="text-[11px]" style={{ color: palette.textMuted }}>
                  {isDarkMode ? 'Peaceful, glare-free night reflections' : 'Gentle warm paper illumination'}
                </div>
              </div>
            </div>

            <button
              onClick={() => {
                const nextDark = !isDarkMode;
                setIsDarkMode(nextDark);
                if (!nextDark && themePreset !== 'light_linen') {
                  setThemePreset('light_linen');
                } else if (nextDark && themePreset === 'light_linen') {
                  setThemePreset('midnight_amber');
                }
              }}
              className="px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all active:scale-95"
              style={{
                backgroundColor: `${palette.primary}18`,
                borderColor: `${palette.primary}40`,
                color: palette.primary,
              }}
            >
              Toggle
            </button>
          </div>

          {/* Theme Palette Cards */}
          <div className="space-y-2.5">
            <span
              className="text-xs font-semibold uppercase tracking-wider block"
              style={{ color: palette.textMuted }}
            >
              Curated Color Presets
            </span>

            {presets.map((preset) => {
              const isSelected = themePreset === preset.id;
              return (
                <button
                  key={preset.id}
                  onClick={() => {
                    setThemePreset(preset.id as ThemePresetId);
                    if (preset.id === 'light_linen') {
                      setIsDarkMode(false);
                    } else {
                      setIsDarkMode(true);
                    }
                  }}
                  className="w-full text-left p-3.5 rounded-2xl border transition-all hover:scale-[1.01] active:scale-[0.99] flex items-center justify-between gap-3 shadow-sm"
                  style={{
                    backgroundColor: preset.surface,
                    borderColor: isSelected ? preset.primary : palette.border,
                    boxShadow: isSelected ? `0 0 16px ${preset.accentGlow}` : undefined,
                  }}
                >
                  <div className="flex items-center gap-3">
                    {/* Swatch preview dots */}
                    <div className="flex items-center -space-x-1.5">
                      <div
                        className="w-5 h-5 rounded-full border border-black/20"
                        style={{ backgroundColor: preset.primary }}
                      />
                      <div
                        className="w-5 h-5 rounded-full border border-black/20"
                        style={{ backgroundColor: preset.secondary }}
                      />
                      <div
                        className="w-5 h-5 rounded-full border border-black/20"
                        style={{ backgroundColor: preset.background }}
                      />
                    </div>

                    <div>
                      <div className="flex items-center gap-2">
                        <span
                          className="font-bold text-sm tracking-tight"
                          style={{ color: preset.textPrimary }}
                        >
                          {preset.englishName}
                        </span>
                        <span
                          className="text-xs font-medium px-2 py-0.5 rounded-md"
                          style={{
                            backgroundColor: `${preset.primary}20`,
                            color: preset.primary,
                          }}
                        >
                          {preset.tamilName}
                        </span>
                      </div>
                      <p
                        className="text-xs leading-snug mt-0.5 line-clamp-1"
                        style={{ color: preset.textSecondary }}
                      >
                        {preset.description}
                      </p>
                    </div>
                  </div>

                  {isSelected && (
                    <div
                      className="w-6 h-6 rounded-full flex items-center justify-center shrink-0 shadow-sm"
                      style={{
                        backgroundColor: preset.primary,
                        color: '#ffffff',
                      }}
                    >
                      <Check className="w-4 h-4" />
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};
