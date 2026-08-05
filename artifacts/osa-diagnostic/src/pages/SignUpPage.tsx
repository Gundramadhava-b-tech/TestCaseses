import { useState } from "react";
import { Link, useLocation } from "wouter";
import { motion } from "framer-motion";
import { AeroDiagLogo } from "@/components/AeroDiagLogo";
import { Eye, EyeOff, ArrowRight, AlertCircle, ArrowLeft, ShieldCheck } from "lucide-react";
import { createUserWithEmailAndPassword, updateProfile } from "firebase/auth";
import { auth } from "@/lib/firebase";

export default function SignUpPage() {
  const [, navigate] = useLocation();
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [verifyPassword, setVerifyPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showVerifyPassword, setShowVerifyPassword] = useState(false);
  const [loading, setLoading] = useState(false);
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
      await updateProfile(userCredential.user, {
        displayName: username,
      });
      navigate("/dashboard");
    } catch (err: any) {
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

  return (
    <div
      className="min-h-screen flex flex-col items-center justify-center px-4 relative overflow-hidden py-12 selection:bg-teal-500/20"
      style={{
        background:
          "radial-gradient(ellipse 120% 80% at 50% -20%, #e0faf7 0%, #f4f7fe 50%, #e6f6f5 100%)",
      }}
    >
      {/* Dynamic Background Mesh Grid & Glow Orbs */}
      <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden" aria-hidden="true">
        <div
          className="absolute top-[-160px] left-1/2 -translate-x-1/2 w-[700px] h-[450px] rounded-full opacity-60"
          style={{ background: "radial-gradient(circle, hsl(175 100% 42% / 0.15) 0%, transparent 70%)", filter: "blur(20px)" }}
        />
        <div
          className="absolute bottom-[-120px] left-[-100px] w-[500px] h-[500px] rounded-full opacity-50"
          style={{ background: "radial-gradient(circle, hsl(220 90% 55% / 0.12) 0%, transparent 70%)", filter: "blur(30px)" }}
        />

        <svg className="absolute inset-0 w-full h-full opacity-30" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="signup-grid" width="36" height="36" patternUnits="userSpaceOnUse">
              <path d="M 36 0 L 0 0 0 36" fill="none" stroke="hsl(175 70% 35% / 0.08)" strokeWidth="0.5" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#signup-grid)" />
        </svg>
      </div>

      {/* Top Navigation Bar Back to Splash */}
      <div className="fixed top-6 left-6 z-20">
        <Link href="/">
          <button className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 bg-white/80 backdrop-blur border border-white hover:bg-white hover:text-teal-700 shadow-sm transition-all hover:shadow cursor-pointer">
            <ArrowLeft className="w-4 h-4 text-teal-600" />
            Back to Splash Page
          </button>
        </Link>
      </div>

      <motion.div
        initial={{ opacity: 0, scale: 0.96, y: 15 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        transition={{ duration: 0.35 }}
        className="relative z-10 w-full max-w-[460px]"
      >
        <div className="bg-white/95 backdrop-blur-xl border border-white/90 rounded-[28px] shadow-2xl shadow-teal-900/10 p-7 md:p-9 relative overflow-hidden">
          
          <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-teal-400 via-teal-600 to-cyan-500" />

          {/* Logo & Header */}
          <div className="flex flex-col items-center mb-6 text-center">
            <div className="p-3 rounded-2xl bg-teal-50 border border-teal-100 shadow-sm mb-3">
              <AeroDiagLogo size={42} />
            </div>
            
            <span className="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-teal-50 text-teal-700 border border-teal-200/80">
              <ShieldCheck className="w-3.5 h-3.5 text-teal-600" /> Clinical Account Registration
            </span>

            <h2 className="font-display font-bold text-2xl mt-3 text-slate-900 tracking-tight">Create Physician Account</h2>
            <p className="text-slate-500 text-xs mt-1">Start diagnosing with AeroDiag today.</p>
          </div>

          {/* Error banner */}
          {error && (
            <div className="mb-4 flex items-start gap-2.5 px-3.5 py-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
              <AlertCircle className="w-4 h-4 mt-0.5 shrink-0 text-rose-600" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Username Input */}
            <div>
              <label htmlFor="signup-username" className="block text-xs font-bold uppercase tracking-wider text-slate-700 mb-1.5">
                Full Name / Doctor Name <span className="text-rose-500">*</span>
              </label>
              <input
                id="signup-username"
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Dr. Devika Pillai"
                className="w-full h-11 px-3.5 rounded-xl text-sm font-medium bg-slate-50 border border-slate-200 text-slate-900 focus:outline-none focus:border-teal-500 focus:bg-white focus:ring-2 focus:ring-teal-500/20 transition-all shadow-sm"
                required
              />
            </div>

            {/* Email Input */}
            <div>
              <label htmlFor="signup-email" className="block text-xs font-bold uppercase tracking-wider text-slate-700 mb-1.5">
                Email Address <span className="text-rose-500">*</span>
              </label>
              <input
                id="signup-email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="doctor@aerodiag.org"
                className="w-full h-11 px-3.5 rounded-xl text-sm font-medium bg-slate-50 border border-slate-200 text-slate-900 focus:outline-none focus:border-teal-500 focus:bg-white focus:ring-2 focus:ring-teal-500/20 transition-all shadow-sm"
                required
              />
            </div>

            {/* Password Input */}
            <div>
              <label htmlFor="signup-password" className="block text-xs font-bold uppercase tracking-wider text-slate-700 mb-1.5">
                Password <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <input
                  id="signup-password"
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 6 characters"
                  className="w-full h-11 px-3.5 pr-10 rounded-xl text-sm font-medium bg-slate-50 border border-slate-200 text-slate-900 focus:outline-none focus:border-teal-500 focus:bg-white focus:ring-2 focus:ring-teal-500/20 transition-all shadow-sm"
                  required
                />
                <button
                  type="button"
                  id="toggle-password-btn"
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors p-1 cursor-pointer"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            {/* Verify Password Input */}
            <div>
              <label htmlFor="signup-verify-password" className="block text-xs font-bold uppercase tracking-wider text-slate-700 mb-1.5">
                Verify Password <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <input
                  id="signup-verify-password"
                  type={showVerifyPassword ? "text" : "password"}
                  value={verifyPassword}
                  onChange={(e) => setVerifyPassword(e.target.value)}
                  placeholder="Re-enter password"
                  className="w-full h-11 px-3.5 pr-10 rounded-xl text-sm font-medium bg-slate-50 border border-slate-200 text-slate-900 focus:outline-none focus:border-teal-500 focus:bg-white focus:ring-2 focus:ring-teal-500/20 transition-all shadow-sm"
                  required
                />
                <button
                  type="button"
                  id="toggle-verify-password-btn"
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors p-1 cursor-pointer"
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
              disabled={loading}
              className="w-full flex items-center justify-center gap-2 py-3.5 px-6 rounded-2xl font-bold text-white text-sm shadow-lg shadow-teal-600/30 hover:shadow-xl hover:shadow-teal-600/40 hover:-translate-y-0.5 transition-all duration-200 active:translate-y-0 disabled:opacity-75 cursor-pointer mt-3"
              style={{ background: "linear-gradient(135deg, hsl(175, 100%, 28%), hsl(180, 100%, 22%))" }}
            >
              {loading ? (
                <span className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
              ) : (
                <>Create Physician Account <ArrowRight className="w-4 h-4" /></>
              )}
            </button>
          </form>

          {/* Footer links */}
          <div className="mt-6 pt-4 border-t border-slate-100 text-center">
            <p className="text-xs text-slate-600 font-medium">
              Already have an account?{" "}
              <Link href="/sign-in">
                <span className="text-teal-600 font-bold hover:underline cursor-pointer">Sign in to Portal</span>
              </Link>
            </p>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
