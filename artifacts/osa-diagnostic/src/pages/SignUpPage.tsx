import { useState } from "react";
import { Link, useLocation } from "wouter";
import { motion } from "framer-motion";
import { AeroDiagLogo } from "@/components/AeroDiagLogo";
import { Eye, EyeOff, ArrowRight, AlertCircle } from "lucide-react";
import {
  createUserWithEmailAndPassword,
  signInWithPopup,
  updateProfile,
  signInWithEmailAndPassword,
} from "firebase/auth";
import { auth, googleProvider } from "@/lib/firebase";

export default function SignUpPage() {
  const [, navigate] = useLocation();
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [verifyPassword, setVerifyPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showVerifyPassword, setShowVerifyPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!username || !email || !password || !verifyPassword) {
      setError("Please fill in all required fields.");
      return;
    }
    if (password.length < 6) {
      setError("Password must be at least 6 characters.");
      return;
    }
    if (password !== verifyPassword) {
      setError("Passwords do not match.");
      return;
    }
    setError(null);
    setLoading(true);
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      // Update user display name with username
      await updateProfile(userCredential.user, {
        displayName: username,
      });
      navigate("/dashboard");
    } catch (err: any) {
      const isCapacitor = (window as any).Capacitor !== undefined;
      if (isCapacitor || err?.code === "auth/network-request-failed") {
        console.warn("Offline/Capacitor Auth fallback triggered");
        const mockUser = {
          uid: "offline-clinician-123",
          email: email,
          displayName: username || "Dr. Devika Pillai",
          emailVerified: true,
        };
        localStorage.setItem("dev_mock_session", JSON.stringify(mockUser));
        navigate("/dashboard");
        return;
      }
      console.error("Signup error:", err);
      const code = err?.code ?? "";
      if (code === "auth/email-already-in-use") {
        setError("An account with this email already exists. Try signing in instead.");
      } else if (code === "auth/weak-password") {
        setError("Password must be at least 6 characters.");
      } else if (code === "auth/invalid-email") {
        setError("Please enter a valid email address.");
      } else {
        setError(err?.message || "Failed to create account. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  }

  async function handleGoogleSignUp() {
    setError(null);
    setGoogleLoading(true);
    try {
      const isCapacitor = (window as any).Capacitor !== undefined;
      if (isCapacitor) {
        // Direct local dev mock session fallback on mobile devices to bypass Firebase requirements
        const mockUser = {
          uid: "offline-clinician-123",
          email: "doctor@aerodiag.com",
          displayName: "Dr. Devika Pillai",
          emailVerified: true,
        };
        localStorage.setItem("dev_mock_session", JSON.stringify(mockUser));
        navigate("/dashboard");
        return;
      }

      await signInWithPopup(auth, googleProvider);
      navigate("/dashboard");
    } catch (err: any) {
      console.error("Google sign-up error:", err);
      if (err?.code === "auth/network-request-failed") {
        const mockUser = {
          uid: "offline-clinician-123",
          email: "doctor@aerodiag.com",
          displayName: "Dr. Devika Pillai",
          emailVerified: true,
        };
        localStorage.setItem("dev_mock_session", JSON.stringify(mockUser));
        navigate("/dashboard");
        return;
      }
      if (err?.code !== "auth/popup-closed-by-user") {
        setError(`Google sign-up failed: ${err?.message || err?.code || "Please try again."}`);
      }
    } finally {
      setGoogleLoading(false);
    }
  }

  return (
    <div
      className="min-h-screen flex items-center justify-center px-4 py-8"
      style={{
        background:
          "linear-gradient(135deg, #e8faf8 0%, #f0f4ff 50%, #e8f8f7 100%)",
      }}
    >
      {/* Background blobs */}
      <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden" aria-hidden="true">
        <div className="absolute top-[-180px] right-[-80px] w-[500px] h-[500px] rounded-full"
          style={{ background: "radial-gradient(circle, hsl(175 100% 45% / 0.09) 0%, transparent 70%)" }} />
        <div className="absolute bottom-[-100px] left-[-80px] w-[420px] h-[420px] rounded-full"
          style={{ background: "radial-gradient(circle, hsl(220 90% 55% / 0.07) 0%, transparent 70%)" }} />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.35 }}
        className="relative z-10 w-full max-w-[480px]"
      >
        <div className="bg-white/95 backdrop-blur border border-white/80 rounded-3xl shadow-xl px-10 py-10">
          {/* Logo & Header */}
          <div className="flex flex-col items-center mb-6">
            <AeroDiagLogo size={42} />
            <h2 className="font-display font-extrabold text-2xl mt-4 text-foreground">Create your account</h2>
            <p className="text-muted-foreground text-sm mt-1 text-center">Start diagnosing with AeroDiag today.</p>
          </div>

          {/* Error banner */}
          {error && (
            <div className="mb-4 flex items-start gap-2.5 px-3.5 py-3 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm">
              <AlertCircle className="w-4 h-4 mt-0.5 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          {/* Google SSO */}
          <button
            id="google-sso-btn"
            type="button"
            onClick={handleGoogleSignUp}
            disabled={googleLoading || loading}
            className="w-full flex items-center justify-center gap-2.5 py-3 rounded-full border border-border/60 bg-white text-sm font-semibold text-foreground hover:bg-gray-50 hover:border-border transition-all shadow-sm mb-4 disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {googleLoading ? (
              <span className="w-4 h-4 rounded-full border-2 border-gray-300 border-t-gray-600 animate-spin" />
            ) : (
              <svg viewBox="0 0 24 24" width="18" height="18" xmlns="http://www.w3.org/2000/svg">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
              </svg>
            )}
            Continue with Google
          </button>

          {/* Divider */}
          <div className="flex items-center gap-3 mb-5">
            <div className="flex-1 h-px bg-border/40" />
            <span className="text-[11px] text-muted-foreground font-semibold uppercase tracking-wider">or</span>
            <div className="flex-1 h-px bg-border/40" />
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Username Input */}
            <div>
              <label htmlFor="signup-username" className="block text-xs font-bold text-foreground mb-1.5 uppercase tracking-wider">
                User Name <span className="text-rose-500">*</span>
              </label>
              <input
                id="signup-username"
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Enter your user name"
                className="w-full h-11 px-4 rounded-xl text-sm bg-secondary/20 border border-border/50 text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary/60 focus:bg-white transition-all shadow-inner"
                required
              />
            </div>

            {/* Email Input */}
            <div>
              <label htmlFor="signup-email" className="block text-xs font-bold text-foreground mb-1.5 uppercase tracking-wider">
                Email address <span className="text-rose-500">*</span>
              </label>
              <input
                id="signup-email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@example.com"
                className="w-full h-11 px-4 rounded-xl text-sm bg-secondary/20 border border-border/50 text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary/60 focus:bg-white transition-all shadow-inner"
                required
              />
            </div>

            {/* Password Input */}
            <div>
              <label htmlFor="signup-password" className="block text-xs font-bold text-foreground mb-1.5 uppercase tracking-wider">
                Password <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <input
                  id="signup-password"
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter password (min 6 chars)"
                  className="w-full h-11 px-4 pr-11 rounded-xl text-sm bg-secondary/20 border border-border/50 text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary/60 focus:bg-white transition-all shadow-inner"
                  required
                />
                <button
                  type="button"
                  id="toggle-password-btn"
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            {/* Verify Password Input */}
            <div>
              <label htmlFor="signup-verify-password" className="block text-xs font-bold text-foreground mb-1.5 uppercase tracking-wider">
                Verify Password <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <input
                  id="signup-verify-password"
                  type={showVerifyPassword ? "text" : "password"}
                  value={verifyPassword}
                  onChange={(e) => setVerifyPassword(e.target.value)}
                  placeholder="Re-enter password"
                  className="w-full h-11 px-4 pr-11 rounded-xl text-sm bg-secondary/20 border border-border/50 text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-primary/60 focus:bg-white transition-all shadow-inner"
                  required
                />
                <button
                  type="button"
                  id="toggle-verify-password-btn"
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                  onClick={() => setShowVerifyPassword(!showVerifyPassword)}
                >
                  {showVerifyPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            {/* Submit Button */}
            <button
              id="signup-continue-btn"
              type="submit"
              disabled={loading || googleLoading}
              className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl font-bold text-white text-sm transition-all disabled:opacity-60 hover:shadow-lg hover:-translate-y-0.5 mt-2 shadow-sm"
              style={{ background: "hsl(175, 56%, 64%)" }}
            >
              {loading ? (
                <span className="w-4 h-4 rounded-full border-2 border-white/30 border-t-white animate-spin" />
              ) : (
                <>Create Account <ArrowRight className="w-4 h-4" /></>
              )}
            </button>
          </form>

          {/* Footer links */}
          <p className="text-center text-sm text-muted-foreground mt-6 font-medium">
            Already have an account?{" "}
            <Link href="/sign-in">
              <span className="text-primary font-bold hover:underline cursor-pointer">Sign in</span>
            </Link>
          </p>

          <p className="text-center mt-4">
            <Link href="/">
              <span className="text-xs text-muted-foreground hover:text-foreground hover:underline cursor-pointer font-semibold">
                — Go back
              </span>
            </Link>
          </p>

          <p className="text-center mt-5">
            <span className="text-[11px] text-amber-600 font-bold uppercase tracking-wider select-none">
              Development mode
            </span>
          </p>
        </div>
      </motion.div>
    </div>
  );
}
