use clap::Parser;
use color_eyre::Result;
use color_eyre::eyre::WrapErr;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
	#[arg(long, env = "LISTEN_ADDRESS", default_value = "127.0.0.1:3000")]
	listen_address: String,

	#[command(flatten)]
	verbosity: clap_verbosity_flag::Verbosity,
}

fn main() -> Result<()> {
	let args = Args::parse();

	tracing_subscriber::fmt()
		.with_max_level(args.verbosity)
		.init();

	tracing::debug!("{args:?}");

	run(args).wrap_err("Failed to run")?;

	tracing::info!("Finished running pipeline");

	Ok(())
}

fn run() -> Result<()> {
	$0
}
