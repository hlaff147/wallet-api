package com.hlaff.wallet_api.repository;

import com.hlaff.loggingx.spring.aop.Loggable;
import com.hlaff.wallet_api.enums.Currency;
import com.hlaff.wallet_api.model.Wallet;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@Loggable
public interface WalletRepository extends MongoRepository<Wallet, String>, WalletRepositoryCustom {
    
    Optional<Wallet> findByUserIdAndCurrency(String userId, Currency currency);
}
