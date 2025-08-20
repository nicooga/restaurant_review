import { LoginForm } from "../../src/components/auth/LoginForm";
import { useAuth } from "../../src/hooks/useAuth";
import { useEffect } from "react";

export function loader() {
  // Note: In a real app, you'd check auth status server-side
  // For now, we'll handle client-side redirects in the component
  return null;
}

export default function Login() {
  const { isAuthenticated } = useAuth();

  // Redirect authenticated users to dashboard
  useEffect(() => {
    if (isAuthenticated) {
      window.location.href = "/dashboard";
    }
  }, [isAuthenticated]);

  const handleSwitchToRegister = () => {
    window.location.href = "/register";
  };

  return <LoginForm onSwitchToRegister={handleSwitchToRegister} />;
}
