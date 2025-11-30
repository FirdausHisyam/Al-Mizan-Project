import { createSignal, Show } from 'solid-js';

export function Auth() {
  const [isLogin, setIsLogin] = createSignal(true);
  const [email, setEmail] = createSignal('');
  const [password, setPassword] = createSignal('');
  const [error, setError] = createSignal('');

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    setError('');
    const endpoint = isLogin() ? '/auth/signin' : '/auth/signup';
    
    try {
      const response = await fetch(`http://localhost:3000${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email(), password: password() }),
      });

      if (!response.ok) {
        throw new Error('Authentication failed');
      }

      if (isLogin()) {
        const data = await response.json();
        localStorage.setItem('token', data.token);
        window.location.reload(); // Simple reload to refresh auth state
      } else {
        setIsLogin(true); // Switch to login after signup
        alert('Signup successful! Please login.');
      }
    } catch (_err) {
      setError('Failed to authenticate. Please check credentials.');
    }
  };

  return (
    <div class="auth-container">
      <div class="glass-card">
        <h2>{isLogin() ? 'Login' : 'Sign Up'}</h2>
        <form onSubmit={handleSubmit}>
          <div class="input-group">
            <label for="email">Email</label>
            <input 
              id="email"
              type="email" 
              value={email()} 
              onInput={(e) => setEmail(e.currentTarget.value)} 
              required 
            />
          </div>
          <div class="input-group">
            <label for="password">Password</label>
            <input 
              id="password"
              type="password" 
              value={password()} 
              onInput={(e) => setPassword(e.currentTarget.value)} 
              required 
            />
          </div>
          <Show when={error()}>
            <p class="error">{error()}</p>
          </Show>
          <button type="submit" class="btn-primary">
            {isLogin() ? 'Enter Citadel' : 'Join Citadel'}
          </button>
        </form>
        <p class="toggle-text">
          {isLogin() ? "New here? " : "Already have an account? "}
          <button type="button" class="btn-link" onClick={() => setIsLogin(!isLogin())}>
            {isLogin() ? 'Create Account' : 'Login'}
          </button>
        </p>
      </div>
    </div>
  );
}
