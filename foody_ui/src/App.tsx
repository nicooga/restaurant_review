import React from "react";

function App() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="card max-w-md w-full">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Foody App</h1>
          <p className="text-gray-600 mb-6">
            Welcome to the Foody restaurant review application!
          </p>
          <div className="space-y-3">
            <button className="btn-primary w-full">Get Started</button>
            <button className="btn-secondary w-full">Learn More</button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
