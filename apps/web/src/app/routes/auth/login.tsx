import { LoginForm } from "@/features/auth/components/login-form";
import { useNavigate } from "react-router-dom";
import { paths } from "@/config/paths";

const LoginRoute = () => {
	const navigate = useNavigate();
	return (
		<LoginForm onSuccess={() => navigate(paths.home, { replace: true })} />
	);
};

export default LoginRoute;
