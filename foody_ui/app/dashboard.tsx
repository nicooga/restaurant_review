import { Dashboard } from "../src/pages/Dashboard";
import { useAuth } from "../src/hooks/useAuth";
import { useEffect } from "react";

export function loader() {
  // Note: In a real app, you'd check auth status server-side
  // For now, we'll handle client-side protection in the component
  return null;
}

export default function DashboardRoute() {
  const { isAuthenticated, isLoading } = useAuth();

  // Redirect unauthenticated users to login
  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      window.location.href = "/login";
    }
  }, [isAuthenticated, isLoading]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="card max-w-md w-full text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null; // Will redirect in useEffect
  }

  return <Dashboard />;
}
