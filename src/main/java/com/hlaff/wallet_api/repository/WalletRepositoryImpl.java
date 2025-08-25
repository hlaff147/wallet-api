package com.hlaff.wallet_api.repository;

import com.hlaff.loggingx.spring.aop.Loggable;
import com.hlaff.wallet_api.model.Wallet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;

public class WalletRepositoryImpl implements WalletRepositoryCustom {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Override
    @Loggable
    public Wallet save(Wallet wallet) {
        return mongoTemplate.save(wallet);
    }
}
