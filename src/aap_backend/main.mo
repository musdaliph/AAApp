import Debug "mo:base/Debug";

actor PredictionMarket {

    // Struktur data untuk menyimpan event prediksi
    type PredictionEvent = {
        id: Nat;
        creator: Principal;
        description: Text;
        deadline: Time;
        resolved: Bool;
        outcome: Bool;
        totalBet: Nat;
        betsForYes: Nat;
        betsForNo: Nat;
        bettorsYes: [Principal];
        bettorsNo: [Principal];
    };

    var events: [PredictionEvent] = [];
    var nextEventId: Nat = 0;

    // Membuat event prediksi baru
    public func createPredictionEvent(description: Text, deadline: Time) : async Nat {
        let event = {
            id = nextEventId;
            creator = Principal.self;
            description = description;
            deadline = deadline;
            resolved = false;
            outcome = false;
            totalBet = 0;
            betsForYes = 0;
            betsForNo = 0;
            bettorsYes = [];
            bettorsNo = [];
        };
        events := events # [event];
        nextEventId += 1;
        return event.id;
    };

    // Fungsi untuk memasang taruhan
    public func placeBet(eventId: Nat, betOnYes: Bool) : async Text {
        let eventOpt = events[eventId];
        switch (eventOpt) {
            case (null) { return "Event tidak ditemukan"; };
            case (?event) {
                // Cek apakah event sudah selesai
                if (event.resolved) {
                    return "Event sudah selesai";
                };
                // Tambahkan taruhan
                if (betOnYes) {
                    event.betsForYes += 1;
                    event.bettorsYes := event.bettorsYes # [Principal.self];
                } else {
                    event.betsForNo += 1;
                    event.bettorsNo := event.bettorsNo # [Principal.self];
                };
                event.totalBet += 1;
                return "Taruhan berhasil!";
            };
        };
    };

    // Fungsi untuk menerima hasil dari Chainlink (Oracle)
    public func resolvePrediction(eventId: Nat, outcome: Bool) : async Text {
        let eventOpt = events[eventId];
        switch (eventOpt) {
            case (null) { return "Event tidak ditemukan"; };
            case (?event) {
                if (event.resolved) {
                    return "Event sudah diselesaikan";
                };
                // Set outcome berdasarkan hasil dari Chainlink
                event.outcome := outcome;
                event.resolved := true;
                // Distribusi reward bisa dilakukan setelah ini
                return "Event diselesaikan dengan hasil: " # (if outcome then "Yes" else "No");
            };
        };
    };

    // Fungsi untuk mendistribusikan reward kepada pemenang
    public func distributeReward(eventId: Nat) : async Text {
        let eventOpt = events[eventId];
        switch (eventOpt) {
            case (null) { return "Event tidak ditemukan"; };
            case (?event) {
                if (!event.resolved) {
                    return "Event belum diselesaikan";
                };
                // Logika distribusi reward di sini
                // Misalnya bagi totalBet antara bettorsYes atau bettorsNo tergantung pada outcome
                return "Reward didistribusikan";
            };
        };
    };
};
