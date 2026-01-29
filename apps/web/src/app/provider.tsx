import { type ReactNode, Suspense } from "react";
import { CircularProgress } from "@mui/material";
import { HelmetProvider } from "react-helmet-async";
import { AuthLoader } from "@/lib/auth";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

type AppProviderProps = {
	children: ReactNode;
};

export const AppProvider = ({ children }: AppProviderProps) => {
	const queryClient = new QueryClient();
	return (
		<Suspense fallback={<CircularProgress />}>
			<HelmetProvider>
				<QueryClientProvider client={queryClient}>
					<AuthLoader renderLoading={() => <div>Loading ...</div>}>
						{children}
					</AuthLoader>
				</QueryClientProvider>
			</HelmetProvider>
		</Suspense>
	);
};
