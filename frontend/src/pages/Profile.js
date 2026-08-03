import React, {useState, useEffect} from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import authService from '../services/authService';

export default function Profile(){
  const navigate = useNavigate();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  // Redirect to login if not authenticated
  useEffect(() => {
    if (!authService.isLoggedIn()) {
      navigate('/login', { replace: true });
      return;
    }
  }, [navigate]);

  useEffect(()=>{
    let mounted = true;
    const fetchUsers = () => {
      api.get('/users')
        .then(res=> { if (mounted) setUsers(res.data || []); })
        .catch(err=> {
          console.error('Failed to fetch users', err);
          if (mounted) setUsers([]);
        })
        .finally(()=> { if (mounted) setLoading(false); });
    }

    fetchUsers();
    const id = setInterval(fetchUsers, 10000); // poll every 10s for near real-time updates
    return ()=>{ mounted = false; clearInterval(id); }
  },[])

  if (loading) return (
    <div className="container page-section">
      <section className="card-panel">
        <h2>Profile</h2>
        <p className="cta-note">Loading users…</p>
      </section>
    </div>
  )

  return (
    <div className="container page-section">
      <section className="page-heading">
        <div>
          <h2>Users</h2>
          <p className="cta-note">All users fetched from the backend.</p>
        </div>
      </section>
      <section className="profile-panel">
        {users.length === 0 ? (
          <div className="profile-card">
            <p>No users found.</p>
          </div>
        ) : (
          <div className="table-responsive">
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Full Name</th>
                  <th>Username</th>
                  <th>Email</th>
                  <th>Mobile</th>
                </tr>
              </thead>
              <tbody>
                {users.map(u => (
                  <tr key={u.id}>
                    <td>{u.id}</td>
                    <td>{u.fullName}</td>
                    <td>{u.username}</td>
                    <td>{u.email}</td>
                    <td>{u.mobile || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  )
}
