import { createSignal, Show, onMount } from 'solid-js';
import { Auth } from './components/Auth';
import { Visualiser } from './components/Visualiser';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = createSignal(false);

  onMount(() => {
    const token = localStorage.getItem('token');
    if (token) {
      setIsAuthenticated(true);
    }
  });

  const handleLogout = () => {
    localStorage.removeItem('token');
    setIsAuthenticated(false);
  };

  return (
    <div class="app-container">
      <Show when={isAuthenticated()} fallback={<Auth />}>
        <div class="dashboard glass-card">
          <header>
            <h1>Al-Mizan Project</h1>
            <button type="button" onClick={handleLogout} class="btn-primary" style="width: auto;">Logout</button>
          </header>

          <main>
            <Visualiser />
          </main>
        </div>
      </Show>
    </div>
  );
}

export default App;
