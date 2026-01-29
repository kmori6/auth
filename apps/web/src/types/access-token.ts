export type User = {
	id: string;
	email: string;
};

export type JWT = {
	token: string;
	expiresIn: number;
	tokenType: string;
};

export type LoginResponse = {
	token: JWT;
	user: User;
};
