package com.cookaiga.demo.api.configuration;

import io.jsonwebtoken.security.Keys;
import java.security.Key;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class JwtConfig {

  @Value("${jwt.secret}")
  private String jwtSecret;

  @Value("${jwt.expiration}")
  private long jwtExpiration;

  @Bean
  public Key secretKey() {
    return Keys.hmacShaKeyFor(jwtSecret.getBytes());
  }

  public String getJwtSecret() {
    return jwtSecret;
  }

  public long getJwtExpiration() {
    return jwtExpiration;
  }
}