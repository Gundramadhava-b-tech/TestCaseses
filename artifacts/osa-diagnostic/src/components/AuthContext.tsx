import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { onAuthStateChanged, signOut, type User } from "firebase/auth";
import { auth } from "@/lib/firebase";

export interface DoctorUser {
  uid: string;
  email: string;
  displayName: string;
  role: string;
  hospital: string;
  emailVerified: boolean;
}

export const DOCTOR_DEVIKA_PILLAI: DoctorUser = {
  uid: "dr-devika-pillai",
  email: "dr.devikapillai@aerodiag.org",
  displayName: "Dr. Devika Pillai",
  role: "Senior Pulmonologist & OSA Specialist",
  hospital: "AeroDiag Medical Center",
  emailVerified: true,
};

interface AuthContextValue {
  user: User | DoctorUser | null;
  loading: boolean;
  loginAsDoctor: () => void;
  signOutDoctor: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  loading: true,
  loginAsDoctor: () => {},
  signOutDoctor: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | DoctorUser | null>(null);
  const [loading, setLoading] = useState(true);

  const loginAsDoctor = () => {
    localStorage.setItem("dev_mock_session", JSON.stringify(DOCTOR_DEVIKA_PILLAI));
    setUser(DOCTOR_DEVIKA_PILLAI);
  };

  const signOutDoctor = async () => {
    localStorage.removeItem("dev_mock_session");
    try {
      await signOut(auth);
    } catch {}
    setUser(null);
  };

  useEffect(() => {
    const mockSession = localStorage.getItem("dev_mock_session");
    if (mockSession) {
      try {
        const parsed = JSON.parse(mockSession);
        setUser(parsed);
        setLoading(false);
      } catch {
        localStorage.removeItem("dev_mock_session");
      }
    }

    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      if (firebaseUser) {
        setUser(firebaseUser);
        localStorage.removeItem("dev_mock_session");
      } else {
        if (!localStorage.getItem("dev_mock_session")) {
          setUser(null);
        }
      }
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, loginAsDoctor, signOutDoctor }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}

