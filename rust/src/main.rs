use std::time::SystemTime;
use tigerbeetle_unofficial::{self as tb, error::CreateTransfersError};

#[pollster::main]
async fn main() {
    let client = tb::Client::new(0, "127.0.0.1:3000", 32)
        .expect("creating a tigerbeetle client for benchmark");

    const SAMPLES: usize = 1_000_000;
    const BATCH_SIZE: usize = 8190;

    // Repeat the same test 10 times and pick the best execution
    for tries in 0..10 {
        let mut time_total_ms: usize = 0;
        let mut time_batch_max_ms: usize = 0;

        for i in (0..SAMPLES).step_by(BATCH_SIZE) {
            let mut transfers = Vec::with_capacity(BATCH_SIZE);

            for j in 0..BATCH_SIZE.min(SAMPLES - i) {
                let transfer = tb::Transfer::new((j + 1 + i).try_into().unwrap())
                    .with_credit_account_id(0)
                    .with_debit_account_id(0)
                    .with_code(1)
                    .with_ledger(1)
                    .with_amount(10);
                transfers.push(transfer);
            }

            let start_time = SystemTime::now();
            client
                .create_transfers(transfers)
                .await
                .or_else(|e| match e {
                    // ignore API errors
                    CreateTransfersError::Api(_) => Ok(()),
                    e => Err(e),
                })
                .expect("creating transfers");
            let elapsed = start_time.elapsed().expect("time elapsed").as_millis() as usize;

            time_total_ms += elapsed;
            if elapsed > time_batch_max_ms {
                time_batch_max_ms = elapsed;
            }
        }

        println!("Attempt: {}", tries + 1);
        println!("Total time: {} ms", time_total_ms);
        println!("Max time per batch: {} ms", time_batch_max_ms);
        println!("Transfers per second: {}\n", SAMPLES * 1000 / time_total_ms);
    }
}
