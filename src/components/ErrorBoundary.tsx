import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('[APDM Uncaught UI Error]:', error, errorInfo);
  }

  private handleReset = () => {
    try {
      localStorage.removeItem('apdm_sessions');
      localStorage.removeItem('apdm_memories');
      localStorage.removeItem('apdm_profile');
    } catch (e) {
      // ignore
    }
    window.location.reload();
  };

  public render() {
    if (this.state.hasError) {
      return (
        <div className="flex flex-col items-center justify-center min-h-screen bg-[#0F172A] text-white p-6 text-center">
          <div className="w-16 h-16 mb-4 rounded-2xl bg-amber-500/20 text-amber-400 flex items-center justify-center text-3xl font-bold border border-amber-500/30">
            ⚠️
          </div>
          <h1 className="text-xl font-bold mb-2">APDM Companion Recovery</h1>
          <p className="text-sm text-slate-300 max-w-md mb-6 leading-relaxed">
            The application encountered a display glitch. Tap below to reload fresh.
          </p>
          <div className="flex flex-col sm:flex-row gap-3">
            <button
              onClick={() => window.location.reload()}
              className="px-5 py-2.5 rounded-xl bg-amber-500 text-slate-900 font-semibold text-sm hover:bg-amber-400 transition-colors shadow-lg"
            >
              Reload Application
            </button>
            <button
              onClick={this.handleReset}
              className="px-5 py-2.5 rounded-xl bg-slate-800 text-slate-300 font-semibold text-sm border border-slate-700 hover:bg-slate-700 transition-colors"
            >
              Reset Cache & Reload
            </button>
          </div>
          {this.state.error && (
            <pre className="mt-8 p-3 bg-slate-900/90 text-red-400 text-xs text-left max-w-lg overflow-x-auto rounded-lg border border-red-500/30">
              {this.state.error.message || String(this.state.error)}
            </pre>
          )}
        </div>
      );
    }

    return this.props.children;
  }
}
