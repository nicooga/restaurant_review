import { RegisterForm } from "../../src/components/auth/RegisterForm";
import { useAuth } from "../../src/hooks/useAuth";
import { useEffect } from "react";

export function loader() {
  // Note: In a real app, you'd check auth status server-side
  // For now, we'll handle client-side redirects in the component
  return null;
}

export default function Register() {
  const { isAuthenticated } = useAuth();

  // Redirect authenticated users to dashboard
  useEffect(() => {
    if (isAuthenticated) {
      window.location.href = "/dashboard";
    }
  }, [isAuthenticated]);

  const handleSwitchToLogin = () => {
    window.location.href = "/login";
  };

  return <RegisterForm onSwitchToLogin={handleSwitchToLogin} />;
}
