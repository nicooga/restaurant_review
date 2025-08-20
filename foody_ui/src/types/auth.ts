export interface User {
  id: number;
  email_address: string;
  created_at: string;
  updated_at: string;
}

export interface LoginCredentials {
  email_address: string;
  password: string;
}

export interface RegisterCredentials {
  email_address: string;
  password: string;
  password_confirmation: string;
}

export interface AuthError {
  message: string;
  errors: string[];
}

export interface AuthResponse {
  user: User;
  message?: string;
}

// API response types that match our Rails API
export interface LoginResponse extends User {}

export interface RegisterResponse extends User {}

export interface CurrentUserResponse extends User {}
