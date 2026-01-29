import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { paths } from "@/config/paths";
import { ProtectedRoute } from "@/lib/auth";
import { HomeRoute } from "./routes/app/home";

const routes = createBrowserRouter([
	{
		path: paths.login,
		lazy: () =>
			import("./routes/auth/login").then((m) => ({
				Component: m.default,
			})),
	},
	{
		path: paths.home,
		element: (
			<ProtectedRoute>
				<HomeRoute />
			</ProtectedRoute>
		),
	},
]);

export const AppRouter = () => {
	return <RouterProvider router={routes} />;
};
