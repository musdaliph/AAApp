import Chainlink "mo:chainlink/Chainlink";

actor PredictionMarket {

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

    // Fungsi untuk membuat event prediksi baru
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
                if (event.resolved) {
                    return "Event sudah selesai";
                };
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

    // Fungsi untuk menerima hasil dari Chainlink
    public func resolvePredictionWithChainlink(eventId: Nat, chainlinkRequestId: Text) : async Text {
        let eventOpt = events[eventId];
        switch (eventOpt) {
            case (null) { return "Event tidak ditemukan"; };
            case (?event) {
                if (event.resolved) {
                    return "Event sudah diselesaikan";
                };
                // Ambil data dari oracle Chainlink
                let oracleData = await Chainlink.requestData(chainlinkRequestId);
                // Menetapkan outcome berdasarkan data dari Chainlink
                if (oracleData == "Yes") {
                    event.outcome := true;
                } else {
                    event.outcome := false;
                };
                event.resolved := true;
                return "Event diselesaikan dengan hasil: " # oracleData;
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
                // Logika distribusi reward
                let winningBettors = if (event.outcome) then event.bettorsYes else event.bettorsNo;
                // Simulasikan distribusi reward (logika detail bisa dikembangkan lebih lanjut)
                return "Reward didistribusikan ke " # Nat.toText(Seq.length(winningBettors)) # " bettors.";
            };
        };
    };
};
