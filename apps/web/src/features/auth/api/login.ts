import { env } from "@/config/env";
import type { LoginResponse } from "@/types/access-token";

export const login = async (
	email: string,
	password: string,
): Promise<LoginResponse> => {
	const response = await fetch(`${env.AUTH_BASE_URL}/login`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify({ email, password }),
	});

	if (!response.ok) {
		throw Error(`Login failed with status ${response.status}`);
	}

	const data: LoginResponse = await response.json();
	return data;
};
