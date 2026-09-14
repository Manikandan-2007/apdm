import React from 'react';
import { X, Users, Check, Heart } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { FAMILY_MEMBERS } from '../services/familyRelationshipService';
import { FamilyMemberId } from '../types';

interface ProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const ProfileModal: React.FC<ProfileModalProps> = ({ isOpen, onClose }) => {
  const { palette, profile, activeSpeaker, switchActiveProfile } = useApp();

  if (!isOpen) return null;

  const familyList: { id: FamilyMemberId; name: string; relation: string; icon: string; desc: string }[] = [
    {
      id: 'meenu',
      name: 'Meenu',
      relation: 'Daughter (Chellam)',
      icon: '🌸',
      desc: 'College student, fond of Sunday vendakkai poriyal, art, and cheerful encouragement.',
    },
    {
      id: 'dinesh',
      name: 'Dinesh',
      relation: 'Son (Magan)',
      icon: '💼',
      desc: 'Entrepreneur managing business responsibilities, guided by integrity and hard work.',
    },
    {
      id: 'padma',
      name: 'Padma',
      relation: 'Wife / Mother',
      icon: '☕',
      desc: 'Pillar of home, morning filter coffee, family harmony, and enduring companionship.',
    },
    {
      id: 'unknown',
      name: 'Family (General)',
      relation: 'Entire Family',
      icon: '🏡',
      desc: 'General family reflections, collective stories, and timeless values.',
    },
  ];

  return (
    <div
      id="profile-modal"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/75 backdrop-blur-sm animate-fade-in"
    >
      <div
        className="w-full max-w-md max-h-[88vh] flex flex-col rounded-t-3xl sm:rounded-3xl shadow-2xl border overflow-hidden"
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
            <Users className="w-5 h-5" style={{ color: palette.primary }} />
            <h2
              className="text-lg font-bold tracking-tight"
              style={{ color: palette.textPrimary }}
            >
              Family Profiles
            </h2>
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
        <div className="flex-1 overflow-y-auto p-5 space-y-5">
          {/* APDM Companion Card */}
          <div
            className="p-4 rounded-2xl border flex items-center gap-4"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div
              className="w-14 h-14 rounded-full flex items-center justify-center font-bold text-lg shadow-md shrink-0 border"
              style={{
                backgroundColor: `${palette.primary}20`,
                borderColor: palette.primary,
                color: palette.primary,
              }}
            >
              {profile.avatarInitials || 'SU'}
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <h3 className="font-bold text-sm tracking-tight" style={{ color: palette.textPrimary }}>
                  APDM Companion
                </h3>
                <span
                  className="text-[10px] px-1.5 py-0.2 rounded-full font-semibold uppercase tracking-wider"
                  style={{
                    backgroundColor: `${palette.primary}18`,
                    color: palette.primary,
                  }}
                >
                  AI Companion
                </span>
              </div>
              <p className="text-xs mt-1 leading-relaxed" style={{ color: palette.textSecondary }}>
                Preserving cherished family conversations, stories, and wisdom in Tamil, Tanglish, and English.
              </p>
            </div>
          </div>

          {/* Active Family Member Switcher */}
          <div className="space-y-2.5">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider" style={{ color: palette.textSecondary }}>
                Active Speaker Profile
              </span>
              <span className="text-[11px]" style={{ color: palette.textMuted }}>
                Switch who is speaking
              </span>
            </div>

            <div className="space-y-2">
              {familyList.map((member) => {
                const isSelected = activeSpeaker === member.id;
                return (
                  <button
                    key={member.id}
                    onClick={() => {
                      switchActiveProfile(member.id);
                      onClose();
                    }}
                    className="w-full text-left p-3 rounded-2xl border flex items-center justify-between transition-all hover:scale-[1.01] active:scale-[0.99]"
                    style={{
                      backgroundColor: isSelected ? `${palette.primary}12` : palette.card,
                      borderColor: isSelected ? palette.primary : palette.border,
                    }}
                  >
                    <div className="flex items-center gap-3">
                      <div
                        className="w-10 h-10 rounded-xl flex items-center justify-center text-lg shrink-0"
                        style={{
                          backgroundColor: isSelected ? `${palette.primary}25` : `${palette.surface}`,
                        }}
                      >
                        {member.icon}
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-xs" style={{ color: palette.textPrimary }}>
                            {member.name}
                          </span>
                          <span
                            className="text-[10px] px-1.5 py-0.5 rounded-md font-medium"
                            style={{
                              backgroundColor: isSelected ? `${palette.primary}20` : `${palette.border}60`,
                              color: isSelected ? palette.primary : palette.textSecondary,
                            }}
                          >
                            {member.relation}
                          </span>
                        </div>
                        <p className="text-[11px] line-clamp-1 mt-0.5" style={{ color: palette.textMuted }}>
                          {member.desc}
                        </p>
                      </div>
                    </div>

                    {isSelected && (
                      <div
                        className="w-6 h-6 rounded-full flex items-center justify-center shrink-0"
                        style={{ backgroundColor: palette.primary, color: '#ffffff' }}
                      >
                        <Check className="w-3.5 h-3.5" />
                      </div>
                    )}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Privacy & Dignity Notice */}
          <div
            className="p-3.5 rounded-2xl border flex items-start gap-2.5"
            style={{
              backgroundColor: `${palette.primary}08`,
              borderColor: `${palette.primary}25`,
            }}
          >
            <Heart className="w-4 h-4 shrink-0 mt-0.5 fill-current" style={{ color: palette.primary }} />
            <div className="text-[11px] leading-relaxed" style={{ color: palette.textSecondary }}>
              <span className="font-semibold" style={{ color: palette.textPrimary }}>
                Family Connection:
              </span>{' '}
              APDM responds thoughtfully with tailored memories and warmth for each family member while keeping all conversations private.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
