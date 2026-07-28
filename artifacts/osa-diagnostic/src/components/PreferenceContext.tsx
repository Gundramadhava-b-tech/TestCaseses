import { createContext, useContext, useEffect, useState, type ReactNode } from "react";

interface PreferenceContextValue {
  language: string;
  setLanguage: (lang: string) => void;
  unit: "mm2" | "cm2";
  setUnit: (unit: "mm2" | "cm2") => void;
  theme: "light" | "dark";
  setTheme: (theme: "light" | "dark") => void;
}

const PreferenceContext = createContext<PreferenceContextValue | null>(null);

export function PreferenceProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<string>(
    () => localStorage.getItem("settings_language") || "en"
  );
  const [unit, setUnitState] = useState<"mm2" | "cm2">(
    () => (localStorage.getItem("settings_unit") as "mm2" | "cm2") || "mm2"
  );
  const [theme, setThemeState] = useState<"light" | "dark">(
    () => (localStorage.getItem("settings_theme") as "light" | "dark") || "light"
  );

  useEffect(() => {
    if (theme === "dark") {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  }, [theme]);

  const setLanguage = (lang: string) => {
    setLanguageState(lang);
    localStorage.setItem("settings_language", lang);
  };

  const setUnit = (newUnit: "mm2" | "cm2") => {
    setUnitState(newUnit);
    localStorage.setItem("settings_unit", newUnit);
  };

  const setTheme = (newTheme: "light" | "dark") => {
    setThemeState(newTheme);
    localStorage.setItem("settings_theme", newTheme);
  };

  return (
    <PreferenceContext.Provider value={{ language, setLanguage, unit, setUnit, theme, setTheme }}>
      {children}
    </PreferenceContext.Provider>
  );
}

export function usePreferences() {
  const context = useContext(PreferenceContext);
  if (!context) {
    throw new Error("usePreferences must be used within a PreferenceProvider");
  }
  return context;
}
