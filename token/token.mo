actor Token {
    // Mendefinisikan tipe data untuk saldo pengguna
    var balances: Trie.Trie<Principal, Nat> = Trie.empty();

    // Mendefinisikan event dan memulai saldo token
    public func mint(to: Principal, amount: Nat) : async Text {
        let current_balance = switch (Trie.get(balances, to)) {
            case (?balance) { balance };
            case (null) { 0 };
        };
        
        // Update saldo baru setelah minting
        let new_balance = current_balance + amount;
        balances := Trie.put(balances, to, new_balance);

        return "Minted " # Nat.toText(amount) # " tokens to " # Principal.toText(to);
    };

    // Fungsi untuk transfer token antar pengguna
    public func transfer(to: Principal, amount: Nat) : async Text {
        let sender = Principal.self;
        let sender_balance = switch (Trie.get(balances, sender)) {
            case (?balance) { balance };
            case (null) { 0 };
        };

        if (sender_balance < amount) {
            return "Insufficient balance.";
        };

        // Update saldo pengirim
        let new_sender_balance = sender_balance - amount;
        balances := Trie.put(balances, sender, new_sender_balance);

        // Update saldo penerima
        let recipient_balance = switch (Trie.get(balances, to)) {
            case (?balance) { balance };
            case (null) { 0 };
        };
        let new_recipient_balance = recipient_balance + amount;
        balances := Trie.put(balances, to, new_recipient_balance);

        return "Transferred " # Nat.toText(amount) # " tokens from " # Principal.toText(sender) # " to " # Principal.toText(to);
    };

    // Fungsi untuk memeriksa saldo pengguna
    public func balanceOf(owner: Principal) : async Nat {
        switch (Trie.get(balances, owner)) {
            case (?balance) { balance };
            case (null) { 0 };
        }
    };
};
