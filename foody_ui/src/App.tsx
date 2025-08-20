import { useCurrentUser } from "./hooks/useCurrentUser";

function App() {
  const { user, isAuthenticated, isLoading } = useCurrentUser();

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

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="card max-w-md w-full">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Foody App</h1>

          {isAuthenticated ? (
            <div>
              <p className="text-green-600 mb-4">
                Welcome back, {user?.email_address}!
              </p>
              <p className="text-gray-600 mb-6">
                You are successfully authenticated.
              </p>
              <button className="btn-secondary w-full">Go to Dashboard</button>
            </div>
          ) : (
            <div>
              <p className="text-gray-600 mb-6">
                Welcome to the Foody restaurant review application!
              </p>
              <div className="space-y-3">
                <button className="btn-primary w-full">Login</button>
                <button className="btn-secondary w-full">Sign Up</button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
