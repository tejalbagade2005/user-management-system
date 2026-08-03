import api from './api';

const authService = {
  register: (payload) => api.post('/auth/register', payload),
  login: (payload) => api.post('/auth/login', payload),
  logout: () => api.post('/auth/logout').catch(err => {
    if (err.response?.status === 401) {
      return null;
    }
    throw err;
  }),

  isLoggedIn: () => {
    const token = localStorage.getItem('token');
    return !!token;
  },

  getStoredToken: () => localStorage.getItem('token'),

  getStoredUser: () => localStorage.getItem('user'),

  clearAuth: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    localStorage.removeItem('username');
    sessionStorage.clear();
  },
};

export default authService;
