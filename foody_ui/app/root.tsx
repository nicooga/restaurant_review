import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  isRouteErrorResponse,
} from "react-router";
import { QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { queryClient } from "../src/lib/query-client";
import "../src/index.css";

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
        <title>Foody - Restaurant Reviews</title>
      </head>
      <body>
        <QueryClientProvider client={queryClient}>
          {children}
          <ReactQueryDevtools initialIsOpen={false} />
        </QueryClientProvider>
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

export default function Root() {
  return <Outlet />;
}

export function ErrorBoundary({ error }: any) {
  let message = "Oops!";
  let details = "An unexpected error occurred.";
  let stack: string | undefined;

  if (isRouteErrorResponse(error)) {
    message = error.status === 404 ? "404" : "Error";
    details =
      error.status === 404
        ? "The requested page could not be found."
        : error.statusText || details;
  } else if (error && error instanceof Error) {
    details = error.message;
    stack = error.stack;
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="card max-w-md w-full text-center">
        <h1 className="text-2xl font-bold text-red-600 mb-4">{message}</h1>
        <p className="text-gray-600 mb-4">{details}</p>
        {stack && (
          <pre className="text-left text-xs bg-gray-100 p-4 rounded overflow-auto">
            {stack}
          </pre>
        )}
        <button
          onClick={() => window.location.reload()}
          className="btn-primary"
        >
          Try Again
        </button>
      </div>
    </div>
  );
}
