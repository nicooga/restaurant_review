import { redirect } from "react-router";

export function loader() {
  return redirect("/dashboard");
}

export default function Home() {
  // This component should never render since we always redirect
  return null;
}
