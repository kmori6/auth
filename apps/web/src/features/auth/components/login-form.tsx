import { useState } from "react";
import {
	Box,
	Button,
	Container,
	TextField,
	Typography,
	Paper,
	Alert,
} from "@mui/material";

import { useLogin } from "@/lib/auth";

export type LoginFormProps = {
	onSuccess: () => void;
};

export const LoginForm = ({ onSuccess }: LoginFormProps) => {
	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");
	const [error, setError] = useState("");

	const login = useLogin();

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault();
		setError("");

		try {
			await login.mutateAsync({ email, password });
			onSuccess();
		} catch (err) {
			setError(err instanceof Error ? err.message : "An error occurred");
		}
	};

	return (
		<Container maxWidth="sm">
			<Box
				sx={{
					marginTop: 8,
					display: "flex",
					flexDirection: "column",
					alignItems: "center",
				}}
			>
				<Paper elevation={3} sx={{ padding: 4, width: "100%" }}>
					<Typography component="h1" variant="h5" align="center" gutterBottom>
						Login
					</Typography>

					{error && (
						<Alert severity="error" sx={{ mb: 2 }}>
							{error}
						</Alert>
					)}

					<Box component="form" onSubmit={handleSubmit} sx={{ mt: 1 }}>
						<TextField
							margin="normal"
							required
							fullWidth
							id="email"
							label="Email Address"
							name="email"
							autoComplete="email"
							autoFocus
							value={email}
							onChange={(e) => setEmail(e.target.value)}
						/>
						<TextField
							margin="normal"
							required
							fullWidth
							name="password"
							label="Password"
							type="password"
							id="password"
							autoComplete="current-password"
							value={password}
							onChange={(e) => setPassword(e.target.value)}
						/>
						<Button
							type="submit"
							fullWidth
							variant="contained"
							sx={{ mt: 3, mb: 2 }}
							disabled={login.isPending}
						>
							{login.isPending ? "Logging in..." : "Login"}
						</Button>
					</Box>
				</Paper>
			</Box>
		</Container>
	);
};
