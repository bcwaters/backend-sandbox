# Authentication Service Tutorial

## Why Authentication Service?

A dedicated Authentication Service in a microservices architecture provides centralized authentication and authorization management. Key benefits include:

1. **Security Isolation**: Separates security concerns from business logic
2. **Single Source of Truth**: Centralized user authentication state
3. **Consistent Security Policies**: Unified security implementation
4. **Scalability**: Independent scaling of authentication operations
5. **Token Management**: Centralized JWT handling and validation

## Getting Started

### Prerequisites
- Node.js (v16 or later)
- PostgreSQL database
- Redis (for token storage/blacklisting)

### Basic Setup

1. Create a new NestJS service:
```bash
nest new auth-service
cd auth-service
```

2. Install required dependencies:
```bash
npm install @nestjs/jwt @nestjs/passport passport passport-jwt passport-local bcrypt class-validator class-transformer
```

3. Set up the authentication module:
```typescript
// src/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '1h' },
    }),
  ],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

### Implementing Authentication

1. Create JWT Strategy:
```typescript
// src/auth/jwt.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  async validate(payload: any) {
    return { userId: payload.sub, username: payload.username };
  }
}
```

2. Implement Authentication Service:
```typescript
// src/auth/auth.service.ts
import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(private jwtService: JwtService) {}

  async validateUser(username: string, password: string): Promise<any> {
    // Implement user validation
  }

  async login(user: any) {
    const payload = { username: user.username, sub: user.userId };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
```

## Best Practices

1. **Password Security**
   - Use strong hashing algorithms (bcrypt)
   - Implement password policies
   - Store password reset tokens securely

2. **Token Management**
   - Implement token refresh mechanism
   - Maintain token blacklist
   - Set appropriate token expiration

3. **Security Headers**
   - Use HTTPS only
   - Set secure cookie flags
   - Implement CSRF protection

## Advanced Features

### Two-Factor Authentication

Implement 2FA support:

```typescript
import { authenticator } from 'otplib';

@Injectable()
export class TwoFactorAuthService {
  async generateSecret(user: User) {
    const secret = authenticator.generateSecret();
    const otpauthUrl = authenticator.keyuri(
      user.email,
      'Your App',
      secret
    );
    return { secret, otpauthUrl };
  }

  async verifyToken(token: string, secret: string) {
    return authenticator.verify({ token, secret });
  }
}
```

### OAuth Integration

Add support for social login:

```typescript
import { Strategy } from 'passport-google-oauth20';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor() {
    super({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: 'http://localhost:3000/auth/google/callback',
      scope: ['email', 'profile'],
    });
  }

  async validate(accessToken: string, refreshToken: string, profile: any) {
    // Implement user validation/creation
  }
}
```

## Monitoring and Logging

1. Add authentication metrics:
```typescript
const authMetrics = new Counter({
  name: 'auth_attempts_total',
  help: 'Total number of authentication attempts',
  labelNames: ['status'],
});
```

2. Implement secure logging:
```typescript
@Injectable()
export class AuthLogger {
  log(level: string, message: string, metadata: any) {
    // Implement secure logging
    // Ensure sensitive data is not logged
  }
}
```

## Troubleshooting

Common issues and solutions:

1. **Token Issues**
   - Check token expiration settings
   - Verify secret key configuration
   - Validate token signing algorithm

2. **Authentication Failures**
   - Check password hashing
   - Verify user credentials
   - Check database connectivity

3. **Performance Issues**
   - Monitor token validation time
   - Check database query performance
   - Analyze login request patterns

## Security Considerations

1. **Rate Limiting**
```typescript
@UseGuards(ThrottlerGuard)
@Throttle(5, 60)
async login() {
  // Login implementation
}
```

2. **Brute Force Protection**
```typescript
@Injectable()
export class BruteForceGuard {
  private attempts = new Map<string, number>();

  async canActivate(context: ExecutionContext) {
    // Implement brute force protection
  }
}
```

3. **Audit Logging**
```typescript
@Injectable()
export class AuditService {
  async logAuthEvent(event: AuthEvent) {
    // Log authentication events
  }
}
``` 