import asyncio
import pathlib
import typing

import aiohttp
import geopandas as gpd
import typer
from rich.console import Console
from tenacity import (
    Retrying,
    stop_after_attempt,
)

from brokenspoke_analyzer.cli import common
from brokenspoke_analyzer.core import (
    analysis,
    downloader,
    runner,
)

app = typer.Typer()


# pylint: disable=too-many-arguments
@app.command()
def all(
    country: str,
    city: str,
    state: typing.Optional[str] = typer.Argument(None),
    output_dir: typing.Optional[pathlib.Path] = common.OutputDir,
    speed_limit: typing.Optional[int] = common.SpeedLimit,
    block_size: typing.Optional[int] = common.BlockSize,
    block_population: typing.Optional[int] = common.BlockPopulation,
    retries: typing.Optional[int] = common.Retries,
) -> None:
    """Prepare all the required files for an analysis."""
    # Make MyPy happy.
    if not output_dir:
        raise ValueError("`output_dir` must be set")
    if not speed_limit:
        raise ValueError("`speed_limit` must be set")
    if not block_size:
        raise ValueError("`block_size` must be set")
    if not block_population:
        raise ValueError("`block_population` must be set")
    if not retries:
        raise ValueError("`retries` must be set")

    asyncio.run(
        prepare_(
            country,
            state,
            city,
            output_dir,
            speed_limit,
            block_size,
            block_population,
            retries,
        )
    )


# pylint: disable=too-many-locals,too-many-arguments
async def prepare_(
    country: str,
    state: str | None,
    city: str,
    output_dir: pathlib.Path,
    speed_limit: int,
    block_size: int,
    block_population: int,
    retries: int,
) -> typing.Tuple[str, str, pathlib.Path, pathlib.Path, pathlib.Path]:
    """Prepare and kicks off the analysis."""
    # Prepare the output directory.
    output_dir.mkdir(parents=True, exist_ok=True)

    # Prepare the Rich output.
    console = Console()

    # Create retrier instance to use for all downloads
    retryer = Retrying(stop=stop_after_attempt(retries), reraise=True)

    # Retrieve city boundaries.
    with console.status("[bold green]Querying OSM to retrieve the city boundaries..."):
        slug = retryer(
            analysis.retrieve_city_boundaries, output_dir, country, city, state
        )
        city_shp = output_dir / f"{slug}.shp"
        console.log("Boundary files ready.")

    # Download the OSM region file.
    with console.status("[bold green]Downloading the OSM region file..."):
        try:
            if not state:
                raise ValueError
            region_file_path = retryer(analysis.retrieve_region_file, state, output_dir)
        except ValueError:
            region_file_path = retryer(
                analysis.retrieve_region_file, country, output_dir
            )
        console.log("OSM Region file downloaded.")

    # Reduce the osm file with osmium.
    with console.status(f"[bold green]Reducing the OSM file for {city} with osmium..."):
        polygon_file = output_dir / f"{slug}.geojson"
        pfb_osm_file = output_dir / f"{slug}.osm"
        analysis.prepare_city_file(
            output_dir, region_file_path, polygon_file, pfb_osm_file
        )
        console.log(f"OSM file for {city} ready.")

    # Retrieve the state info if needed.
    try:
        if state:
            state_abbrev, state_fips = analysis.state_info(state)
        else:
            state_abbrev, state_fips = analysis.state_info(country)
    except ValueError:
        state_abbrev, state_fips = (
            runner.NON_US_STATE_ABBREV,
            runner.NON_US_STATE_FIPS,
        )

    # Perform some specific operations for non-US cities.
    if str(state_fips) == runner.NON_US_STATE_FIPS:
        # Create synthetic population.
        with console.status("[bold green]Prepare synthetic population..."):
            CELL_SIZE = (block_size, block_size)
            city_boundaries_gdf = gpd.read_file(city_shp)
            synthetic_population = analysis.create_synthetic_population(
                city_boundaries_gdf, *CELL_SIZE, population=block_population
            )
            console.log("Synthetic population ready.")

        # Simulate the census blocks.
        with console.status("[bold green]Simulate census blocks..."):
            analysis.simulate_census_blocks(output_dir, synthetic_population)
            console.log("Census blocks ready.")

        # Change the speed limit.
        with console.status("[bold green]Adjust default speed limit..."):
            analysis.change_speed_limit(output_dir, city, state_abbrev, speed_limit)
            console.log(f"Default speed limit adjusted to {speed_limit} km/h.")
    else:
        async with aiohttp.ClientSession() as session:
            lodes_year = 2019
            with console.status(
                f"[bold green]Fetching {lodes_year} US employment data..."
            ):
                await retryer(
                    downloader.download_lodes_data,
                    session,
                    output_dir,
                    state_abbrev,
                    "main",
                    lodes_year,
                )
                await retryer(
                    downloader.download_lodes_data,
                    session,
                    output_dir,
                    state_abbrev,
                    "aux",
                    lodes_year,
                )

            with console.status("[bold green]Fetching US census waterblocks..."):
                await retryer(
                    downloader.download_census_waterblocks, session, output_dir
                )

            with console.status("[bold green]Fetching 2010 US census blocks..."):
                await retryer(
                    downloader.download_2010_census_blocks,
                    session,
                    output_dir,
                    state_fips,
                )

            with console.status("[bold green]Fetching US state speed limits..."):
                await retryer(
                    downloader.download_state_speed_limits, session, output_dir
                )

            with console.status("[bold green]Fetching US city speed limits..."):
                await retryer(
                    downloader.download_city_speed_limits, session, output_dir
                )

    # Return the parameters required to perform the analysis.
    # pylint: disable=duplicate-code
    return (
        state_abbrev,
        state_fips,
        city_shp,
        pfb_osm_file,
        output_dir,
    )
