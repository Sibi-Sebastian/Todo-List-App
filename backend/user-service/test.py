import unittest
import json
import bcrypt
from app import app, init_db, hash_password, verify_password, generate_token, verify_token

class UserServiceTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        init_db()

    def test_health_check(self):
        """Test health check endpoint"""
        response = self.app.get('/health')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(data['status'], 'OK')
        self.assertEqual(data['service'], 'user-service')

    def test_register_user(self):
        """Test user registration"""
        user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123'
        }

        response = self.app.post('/api/auth/register',
                               data=json.dumps(user_data),
                               content_type='application/json')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 201)
        self.assertIn('token', data)
        self.assertIn('user', data)
        self.assertEqual(data['user']['username'], user_data['username'])
        self.assertEqual(data['user']['email'], user_data['email'])

    def test_register_duplicate_user(self):
        """Test registering duplicate user"""
        user_data = {
            'username': 'duplicateuser',
            'email': 'duplicate@example.com',
            'password': 'testpass123'
        }

        # Register first time
        self.app.post('/api/auth/register',
                     data=json.dumps(user_data),
                     content_type='application/json')

        # Try to register again
        response = self.app.post('/api/auth/register',
                               data=json.dumps(user_data),
                               content_type='application/json')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 409)
        self.assertIn('error', data)

    def test_register_invalid_data(self):
        """Test registration with invalid data"""
        # Test missing fields
        response = self.app.post('/api/auth/register',
                               data=json.dumps({'username': 'test'}),
                               content_type='application/json')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 400)
        self.assertIn('error', data)

    def test_login_user(self):
        """Test user login"""
        # First register a user
        user_data = {
            'username': 'logintest',
            'email': 'login@example.com',
            'password': 'testpass123'
        }
        self.app.post('/api/auth/register',
                     data=json.dumps(user_data),
                     content_type='application/json')

        # Now try to login
        login_data = {
            'username': 'logintest',
            'password': 'testpass123'
        }
        response = self.app.post('/api/auth/login',
                               data=json.dumps(login_data),
                               content_type='application/json')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 200)
        self.assertIn('token', data)
        self.assertIn('user', data)
        self.assertEqual(data['user']['username'], user_data['username'])

    def test_login_invalid_credentials(self):
        """Test login with invalid credentials"""
        login_data = {
            'username': 'nonexistent',
            'password': 'wrongpass'
        }

        response = self.app.post('/api/auth/login',
                               data=json.dumps(login_data),
                               content_type='application/json')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 401)
        self.assertIn('error', data)

    def test_get_profile_without_token(self):
        """Test getting profile without token"""
        response = self.app.get('/api/auth/profile')
        data = json.loads(response.data.decode('utf-8'))

        self.assertEqual(response.status_code, 401)
        self.assertIn('error', data)

    def test_password_hashing(self):
        """Test password hashing functions"""
        password = 'testpassword123'

        # Hash password
        hashed = hash_password(password)
        self.assertNotEqual(password, hashed)

        # Verify password
        self.assertTrue(verify_password(password, hashed))
        self.assertFalse(verify_password('wrongpassword', hashed))

    def test_jwt_token(self):
        """Test JWT token generation and verification"""
        user_id = 123

        # Generate token
        token = generate_token(user_id)
        self.assertIsInstance(token, str)

        # Verify token
        decoded_user_id = verify_token(token)
        self.assertEqual(decoded_user_id, user_id)

        # Test invalid token
        self.assertIsNone(verify_token('invalid-token'))

if __name__ == '__main__':
    unittest.main()
