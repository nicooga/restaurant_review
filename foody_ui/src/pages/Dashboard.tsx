import { useAuth } from "../hooks/useAuth";

export const Dashboard = () => {
  const { user, logout, isLoggingOut } = useAuth();

  const handleLogout = async () => {
    try {
      await logout();
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-semibold text-gray-900">
                Foody Dashboard
              </h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">
                Welcome, {user?.email_address}
              </span>
              <button
                onClick={handleLogout}
                disabled={isLoggingOut}
                className="btn-secondary"
              >
                {isLoggingOut ? "Signing out..." : "Sign Out"}
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="card">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                Restaurant Reviews
              </h2>
              <p className="text-gray-600 mb-8">
                Welcome to your dashboard! This is where you'll be able to browse
                and review restaurants.
              </p>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gray-50 p-6 rounded-lg">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    Browse Restaurants
                  </h3>
                  <p className="text-gray-600 text-sm mb-4">
                    Discover new places to eat in your area
                  </p>
                  <button className="btn-primary w-full" disabled>
                    Coming Soon
                  </button>
                </div>
                <div className="bg-gray-50 p-6 rounded-lg">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    My Reviews
                  </h3>
                  <p className="text-gray-600 text-sm mb-4">
                    View and manage your restaurant reviews
                  </p>
                  <button className="btn-primary w-full" disabled>
                    Coming Soon
                  </button>
                </div>
                <div className="bg-gray-50 p-6 rounded-lg">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    Favorites
                  </h3>
                  <p className="text-gray-600 text-sm mb-4">
                    Your favorite restaurants and dishes
                  </p>
                  <button className="btn-primary w-full" disabled>
                    Coming Soon
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};
