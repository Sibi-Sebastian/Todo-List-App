# Database and application configuration
import os

config = {
    'database': {
        'host': os.getenv('DB_HOST', 'localhost'),
        'user': os.getenv('DB_USER', 'root'),
        'password': os.getenv('DB_PASSWORD', 'sian'),
        'database': os.getenv('DB_NAME', 'todo_users'),
        'port': int(os.getenv('DB_PORT', 3306))
    },
    'jwt': {
        'secret': os.getenv('JWT_SECRET', 'your-super-secret-jwt-key-change-in-production')
    },
    'server': {
        'port': int(os.getenv('PORT', 3002)),
        'host': os.getenv('HOST', '0.0.0.0'),
        'debug': os.getenv('DEBUG', 'True').lower() == 'true'
    }
}
