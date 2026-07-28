import { useState, useEffect } from "react";
import { Sun, Moon, Globe, Sliders, Cpu, Bell, Check, Info } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { useToast } from "@/hooks/use-toast";
import { usePreferences } from "@/components/PreferenceContext";
import { t } from "@/lib/translations";

type TabId = "theme" | "language" | "units" | "ai" | "notifications";

export default function Settings() {
  const { toast } = useToast();
  const { language, setLanguage, theme, setTheme, unit, setUnit } = usePreferences();

  const [aiSensitivity, setAiSensitivity] = useState<string>(
    () => localStorage.getItem("settings_ai_sensitivity") || "high"
  );
  const [notifications, setNotifications] = useState({
    critical: true,
    reports: false,
    updates: true,
  });

  const [activeTab, setActiveTab] = useState<TabId>("theme");

  // Apply theme class to HTML element
  const toggleTheme = (newTheme: "light" | "dark") => {
    setTheme(newTheme);
    toast({
      title: "Theme Updated",
      description: `Successfully switched to ${newTheme} mode.`,
    });
  };

  // Sync language setting
  const updateLanguage = (newLang: string, label: string) => {
    setLanguage(newLang);
    toast({
      title: "Language Preference Changed",
      description: `Language set to ${label}.`,
    });
  };

  // Sync diagnostic units
  const updateUnit = (newUnit: "mm2" | "cm2", label: string) => {
    setUnit(newUnit);
    toast({
      title: "Measurement Unit Updated",
      description: `Airway area will now display in ${label}.`,
    });
  };

  // Sync AI engine sensitivity
  const updateAiSensitivity = (newSensitivity: string) => {
    setAiSensitivity(newSensitivity);
    localStorage.setItem("settings_ai_sensitivity", newSensitivity);
    toast({
      title: "AI Sensitivity Updated",
      description: `Detection sensitivity set to ${newSensitivity === "high" ? "High" : newSensitivity === "medium" ? "Medium" : "Low"}.`,
    });
  };

  // Sync Notifications
  const toggleNotification = (key: "critical" | "reports" | "updates") => {
    setNotifications((prev) => {
      const updated = { ...prev, [key]: !prev[key] };
      localStorage.setItem("settings_notifications", JSON.stringify(updated));
      return updated;
    });
    toast({
      title: "Notifications Updated",
      description: "Notification preferences saved successfully.",
    });
  };

  // Initialize saved notification settings
  useEffect(() => {
    const saved = localStorage.getItem("settings_notifications");
    if (saved) {
      try {
        setNotifications(JSON.parse(saved));
      } catch (e) {
        console.error(e);
      }
    }
  }, []);

  const tabs = [
    { id: "theme", label: "appearance_theme", icon: Sun },
    { id: "language", label: "preferred_language", icon: Globe },
    { id: "units", label: "diagnostic_units", icon: Sliders },
    { id: "ai", label: "ai_engine", icon: Cpu },
    { id: "notifications", label: "alerts_notifications", icon: Bell },
  ] as const;

  return (
    <div className="space-y-8">
      {/* ── Page Header ── */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
        <div className="section-header">
          <div className="text-xs font-semibold text-muted-foreground mb-1 tracking-widest uppercase">
            {t("home")} / {t("settings")}
          </div>
          <h1 className="text-4xl font-display font-extrabold text-foreground leading-tight">
            {t("settings_preferences")}
          </h1>
          <p className="text-muted-foreground mt-1 text-sm">
            {t("settings_sub")}
          </p>
        </div>
      </div>

      {/* ── Horizontal Navigation Tabs ── */}
      <div className="flex border-b border-border/80 overflow-x-auto scrollbar-none gap-2 sm:gap-6">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center gap-2.5 pb-4 px-1 border-b-2 font-display text-sm font-semibold whitespace-nowrap transition-all duration-300 relative focus:outline-none ${
                isActive
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              <Icon className={`w-4 h-4 ${isActive ? "text-primary animate-pulse" : "text-muted-foreground"}`} />
              <span>{t(tab.label)}</span>
              {isActive && (
                <motion.div
                  layoutId="activeTabUnderline"
                  className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary"
                  transition={{ type: "spring", stiffness: 380, damping: 30 }}
                />
              )}
            </button>
          );
        })}
      </div>

      {/* ── Active Setting Tab Contents Card ── */}
      <div className="bg-card rounded-2xl border border-card-border p-6 sm:p-8 shadow-xs relative overflow-hidden">
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -15 }}
            transition={{ duration: 0.25, ease: "easeOut" }}
            className="space-y-6"
          >
            {/* 1. Appearance & Theme Content */}
            {activeTab === "theme" && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-4">
                    {t("theme_mode")}
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-2xl">
                    {/* Light Mode Card */}
                    <div
                      onClick={() => toggleTheme("light")}
                      className={`relative flex items-center justify-between p-5 rounded-2xl border cursor-pointer transition-all duration-300 hover:shadow-md ${
                        theme === "light"
                          ? "border-primary bg-primary/5 text-primary"
                          : "border-border bg-card text-foreground"
                      }`}
                    >
                      <div className="flex items-center gap-4">
                        <div className={`p-3 rounded-xl ${theme === "light" ? "bg-primary/10" : "bg-secondary"}`}>
                          <Sun className={`w-6 h-6 ${theme === "light" ? "text-primary" : "text-muted-foreground"}`} />
                        </div>
                        <div>
                          <p className="font-bold text-sm">{t("light_mode")}</p>
                          <p className="text-xs text-muted-foreground mt-0.5">{t("light_mode_desc")}</p>
                        </div>
                      </div>
                      {theme === "light" && (
                        <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center">
                          <Check className="w-3.5 h-3.5 text-white" />
                        </div>
                      )}
                    </div>

                    {/* Dark Mode Card */}
                    <div
                      onClick={() => toggleTheme("dark")}
                      className={`relative flex items-center justify-between p-5 rounded-2xl border cursor-pointer transition-all duration-300 hover:shadow-md ${
                        theme === "dark"
                          ? "border-primary bg-primary/5 text-primary"
                          : "border-border bg-card text-foreground"
                      }`}
                    >
                      <div className="flex items-center gap-4">
                        <div className={`p-3 rounded-xl ${theme === "dark" ? "bg-primary/10" : "bg-secondary"}`}>
                          <Moon className={`w-6 h-6 ${theme === "dark" ? "text-primary" : "text-muted-foreground"}`} />
                        </div>
                        <div>
                          <p className="font-bold text-sm">{t("dark_mode")}</p>
                          <p className="text-xs text-muted-foreground mt-0.5">{t("dark_mode_desc")}</p>
                        </div>
                      </div>
                      {theme === "dark" && (
                        <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center">
                          <Check className="w-3.5 h-3.5 text-white" />
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Footer Info Banner */}
                <div className="flex items-start gap-3 p-4 rounded-xl bg-primary/5 border border-primary/15 text-primary/95 text-xs font-medium max-w-2xl">
                  <Info className="w-4 h-4 mt-0.5 shrink-0" />
                  <p>{t("theme_note")}</p>
                </div>
              </div>
            )}

            {/* 2. Preferred Language Content */}
            {activeTab === "language" && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-4">
                    {t("select_language")}
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-2xl">
                    {[
                      { code: "en", label: "English (US)", text: "English (US)" },
                      { code: "te", label: "Telugu", text: "తెలుగు (Telugu)" },
                      { code: "ta", label: "Tamil", text: "தமிழ் (Tamil)" },
                      { code: "hi", label: "Hindi", text: "हिन्दी (Hindi)" },
                    ].map((lang) => (
                      <div
                        key={lang.code}
                        onClick={() => updateLanguage(lang.code, lang.label)}
                        className={`relative flex items-center justify-between p-5 rounded-2xl border cursor-pointer transition-all duration-300 hover:shadow-md ${
                          language === lang.code
                            ? "border-primary bg-primary/5 text-primary"
                            : "border-border bg-card text-foreground"
                        }`}
                      >
                        <span className="font-bold text-sm">{lang.text}</span>
                        {language === lang.code && (
                          <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center">
                            <Check className="w-3.5 h-3.5 text-white" />
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* 3. Diagnostic Units Content */}
            {activeTab === "units" && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-4">
                    {t("airway_unit")}
                  </h3>
                  <div className="flex flex-col gap-4 max-w-2xl">
                    {/* mm2 Unit Card */}
                    <div
                      onClick={() => updateUnit("mm2", t("sq_mm"))}
                      className={`relative flex items-center justify-between p-5 rounded-2xl border cursor-pointer transition-all duration-300 hover:shadow-md ${
                        unit === "mm2"
                          ? "border-primary bg-primary/5 text-primary"
                          : "border-border bg-card text-foreground"
                      }`}
                    >
                      <div>
                        <p className="font-bold text-sm">{t("sq_mm")}</p>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {t("sq_mm_desc")}
                        </p>
                      </div>
                      {unit === "mm2" && (
                        <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center">
                          <Check className="w-3.5 h-3.5 text-white" />
                        </div>
                      )}
                    </div>

                    {/* cm2 Unit Card */}
                    <div
                      onClick={() => updateUnit("cm2", t("sq_cm"))}
                      className={`relative flex items-center justify-between p-5 rounded-2xl border cursor-pointer transition-all duration-300 hover:shadow-md ${
                        unit === "cm2"
                          ? "border-primary bg-primary/5 text-primary"
                          : "border-border bg-card text-foreground"
                      }`}
                    >
                      <div>
                        <p className="font-bold text-sm">{t("sq_cm")}</p>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {t("sq_cm_desc")}
                        </p>
                      </div>
                      {unit === "cm2" && (
                        <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center">
                          <Check className="w-3.5 h-3.5 text-white" />
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* 4. AI Engine Content */}
            {activeTab === "ai" && (
              <div className="space-y-6">
                <div className="max-w-2xl space-y-6">
                  {/* Neural Engine Badge Card */}
                  <div className="flex items-center gap-4 p-4 rounded-xl bg-blue-500/5 border border-blue-500/15 text-blue-700 dark:text-blue-400">
                    <div className="p-2.5 rounded-lg bg-blue-500/10">
                      <Cpu className="w-5 h-5" />
                    </div>
                    <div>
                      <p className="text-sm font-bold">Gemini 2.5 Flash Neural Engine Active</p>
                      <p className="text-xs text-muted-foreground mt-0.5">Real-time 3D Pharyngeal Airway Segmentation</p>
                    </div>
                  </div>

                  {/* Detection Sensitivity Dropdown */}
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-muted-foreground uppercase tracking-widest block">
                      {t("sensitivity")}
                    </label>
                    <select
                      value={aiSensitivity}
                      onChange={(e) => updateAiSensitivity(e.target.value)}
                      className="w-full max-w-md h-12 px-4 rounded-xl border border-border bg-card text-foreground font-semibold focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary shadow-xs"
                    >
                      <option value="high">{t("sensitivity_high")}</option>
                      <option value="medium">{t("sensitivity_med")}</option>
                      <option value="low">{t("sensitivity_low")}</option>
                    </select>
                  </div>
                </div>
              </div>
            )}

            {/* 5. Alerts & Notifications Content */}
            {activeTab === "notifications" && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-4">
                    {t("alerts_notifications")}
                  </h3>
                  <div className="flex flex-col gap-4 max-w-2xl">
                    {[
                      {
                        key: "critical",
                        label: "critical_alerts",
                        desc: "critical_alerts_desc",
                      },
                      {
                        key: "reports",
                        label: "email_reports",
                        desc: "email_reports_desc",
                      },
                      {
                        key: "updates",
                        label: "system_updates",
                        desc: "system_updates_desc",
                      },
                    ].map((item) => (
                      <div
                        key={item.key}
                        onClick={() => toggleNotification(item.key as any)}
                        className="flex items-start justify-between p-5 rounded-2xl border border-border bg-card cursor-pointer transition-all duration-300 hover:shadow-md"
                      >
                        <div className="space-y-1">
                          <p className="font-bold text-sm text-foreground">{t(item.label)}</p>
                          <p className="text-xs text-muted-foreground">{t(item.desc)}</p>
                        </div>
                        {/* Toggle switch visual */}
                        <div
                          className={`w-11 h-6 rounded-full transition-colors duration-300 relative shrink-0 ${
                            (notifications as any)[item.key] ? "bg-primary" : "bg-secondary"
                          }`}
                        >
                          <div
                            className={`w-5 h-5 rounded-full bg-white absolute top-0.5 shadow-sm transition-transform duration-300 ${
                              (notifications as any)[item.key] ? "translate-x-5.5" : "translate-x-0.5"
                            }`}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </motion.div>
        </AnimatePresence>
      </div>
    </div>
  );
}
