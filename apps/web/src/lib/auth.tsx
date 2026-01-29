import { login } from "@/features/auth/api/login";
import { configureAuth } from "react-query-auth";
import type { User } from "@/types/access-token";
import type { ReactNode } from "react";
import { Navigate } from "react-router";
import { paths } from "@/config/paths";
import { env } from "@/config/env";

const TOKEN_KEY = "auth_token";

const getUser = async (): Promise<User | null> => {
	const token = localStorage.getItem(TOKEN_KEY);
	if (!token) {
		return null;
	}

	try {
		const response = await fetch(`${env.AUTH_BASE_URL}/me`, {
			headers: {
				Authorization: `Bearer ${token}`,
			},
		});

		if (!response.ok) {
			localStorage.removeItem(TOKEN_KEY);
			return null;
		}

		const user: User = await response.json();
		return user;
	} catch {
		localStorage.removeItem(TOKEN_KEY);
		return null;
	}
};

const registerUser = async (): Promise<User | null> => {
	// Implementation to register a new user
	return null;
};

const logout = async () => {
	// Implementation to log out the user
};

const authConfig = {
	userFn: getUser,
	loginFn: async (data: { email: string; password: string }) => {
		const response = await login(data.email, data.password);
		localStorage.setItem(TOKEN_KEY, response.token.token);
		return response.user;
	},
	registerFn: registerUser,
	logoutFn: logout,
};

export const { useUser, useLogin, useRegister, useLogout, AuthLoader } =
	configureAuth(authConfig);

export const ProtectedRoute = ({ children }: { children: ReactNode }) => {
	const user = useUser();

	if (!user.data) {
		return <Navigate to={paths.login} replace />;
	}

	return children;
};
