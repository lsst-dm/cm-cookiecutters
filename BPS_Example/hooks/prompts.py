import os
import sys
from collections import OrderedDict
from pathlib import Path

from rich.console import Console
from rich.prompt import Prompt, Confirm
from rich.panel import Panel

# Cookiecutter doesn't manage sys path very explicitly when calling hooks
# TODO probably should just use importlib for this import
CC_HOME = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(CC_HOME))
from local_extensions import as_datetime, as_snake_case, as_lsst_version  # noqa: E402

console = Console()


def prompt_cookiecutter(context: OrderedDict):
    context["_project_name"] = Prompt.ask(
        "A short (3-5 word) description of your workflow",
        default="BPS Example Configuration",
    )
    context["project_slug"] = as_snake_case(context["_project_name"]).lower()


def prompt_lsst(context: OrderedDict):
    console.print(Panel.fit("=== LSST Workflow Information ==="))

    lsst_manifest: OrderedDict = context["_manifests"]["lsst"]

    lsst_manifest["description"] = context["_project_name"]
    lsst_manifest["ticket"] = Prompt.ask(
        "[cyan]Jira DM Ticket Number[/cyan]",
        default="DM-XXXXX",
    )
    lsst_manifest["project"] = Prompt.ask(
        "[cyan][green]Project[/green] or [green]Epic[/green] with which this workflow is associated[/cyan]",
        default=None,
    )
    lsst_manifest["campaign"] = Prompt.ask(
        "[cyan][green]Campaign[/green] with which this workflow is associated[/cyan]",
        default=None,
    )

    console.print(Panel.fit("=== LSST Stack Configuration ==="))

    console.print("[cyan]What version of the [green]stack[/green] will your workflow use?[/cyan]")
    console.print(
        f"[green]Today is [cyan]{as_datetime(context['_today'])}[/cyan][/green]"
    )
    console.print(
        f"[green]That corresponds to [cyan]{as_lsst_version(as_datetime(context['_today']))}[/cyan][/green]"
    )
    lsst_manifest["lsst_version"] = Prompt.ask(
        "[cyan]Or you can go with the default[/cyan]",
        default="w_latest",
    )


def prompt_wms(context: OrderedDict):

    wms_manifest: OrderedDict = context["_manifests"]["wms"]

    console.print(Panel.fit("=== WMS Workflow Information ==="))

    wms_batch_system = Prompt.ask(
        "What WMS Batch System do you want to run this on?",
        choices=["htcondor", "PanDA"],
        default="htcondor",
    )
    match wms_batch_system:
        case "htcondor":
            wms_manifest["service_class"] = "lsst.ctrl.bps.htcondor.HTCondorService"
            prompt_htcondor(context)
        case "PanDA":
            wms_manifest["service_class"] = "lsst.ctrl.bps.panda.PanDAService"


def prompt_bps(context: OrderedDict):
    bps_manifest: OrderedDict = context["_manifests"]["bps"]

    console.print(Panel.fit("=== BPS Workflow Information ==="))

    bps_manifest["operator"] = Prompt.ask(
        "[cyan]What username should this workflow belong to?[/cyan]",
        default=os.getenv("USER"),
    )
    bps_manifest["payload"] = {}
    bps_manifest["payload"]["payloadName"] = Prompt.ask(
        "[cyan]What is name of this payload?[/cyan]\n[dark_orange]This will be part of the output collection name[/dark_orange]\n",
        default=context["project_slug"],
    )

    bps_manifest["payload"]["output"] = Prompt.ask(
        "[cyan]What is the [dark_orange]Output[/dark_orange] Collection?",
        default="u/{operator}/{payloadName}",
    )
    bps_manifest["payload"]["outputRun"] = Prompt.ask(
        "[cyan]That makes the [dark_orange]Output Run[/dark_orange] Collection:",
        default="{output}/{timestamp}",
    )
    bps_manifest["payload"]["butlerConfig"] = Prompt.ask(
        "[cyan]What [green]Butler[/green] repo are we using?[/cyan]",
        default="repo/main",
    )
    bps_manifest["payload"]["inCollection"] = Prompt.ask(
        "[cyan]What will we use for the [dark_orange]Input[/dark_orange] Collection?[/cyan]",
        default="LSSTCam/defaults",
    )
    bps_manifest["payload"]["dataQuery"] = Prompt.ask(
        "[cyan]What will we use for the [dark_orange]Butler Data Query[/dark_orange][/cyan]",
        default="instrument='LSSTCam' AND skymap='lsst_cells_v2'",
    )

    bps_manifest["pipeline_yaml"] = None
    bps_manifest["qgraph_file"] = Prompt.ask(
        "[cyan]If you already have a [dark_orange]Qgraph[/dark_orange] file, what is it?[/cyan]",
        default=None,
    )
    if bps_manifest["qgraph_file"] is None:
        bps_manifest["pipeline_yaml"] = Prompt.ask(
            "[cyan]What is the [dark_orange]Pipeline YAML[/dark_orange] for this workflow?",
            default="${PIPE_DIR}/path/to/some/pipeline.yaml#anchor",
        )


def prompt_butler(context: OrderedDict): ...


def prompt_htcondor(context: OrderedDict):
    wms_manifest: OrderedDict = context["_manifests"]["wms"]

    console.print(Panel.fit("=== HTCondor Information ==="))

    wms_manifest["auto_provision"] = Confirm.ask(
        "[cyan]Do you want BPS to provision resources for your workflow?[/cyan]\nThis means running [dark_orange]allocateNodes.py[/dark_orange] for you",
        default=True,
    )

    if wms_manifest["auto_provision"]:
        console.print(Panel.fit("=== HTCondor Provisioning Information ==="))
        wms_manifest["provisioned_node_count"] = Prompt.ask(
            "[cyan]How many nodes should be provisioned for your [dark_orange]glidein[/dark_orange]?[/cyan]",
            default="10",
        )
        wms_manifest["provisioned_max_wall_time"] = Prompt.ask(
            "[cyan]What is the maximum [green]wallclock lifetime[/green] of your [dark_orange]glidein[/dark_orange]?[/cyan]",
            default="2-0:0:0",
        )
        wms_manifest["provisioned_idle_time"] = Prompt.ask(
            "[cyan]What is the maximum [green]idle lifetime[/green] of your [dark_orange]glidein[/dark_orange]?[/cyan]",
            default="600",
        )
        wms_manifest["provisioned_check_interval"] = Prompt.ask(
            "[cyan]How often should BPS check for new jobs to feed your [dark_orange]glidein[/dark_orange]?[/cyan]",
            default="600",
        )
        wms_manifest["provisioned_extra_arguments"] = ""
    else:
        console.print(Panel.fit("=== HTCondor GlideIn Information ==="))
        wms_manifest["batch_name"] = Prompt.ask(
            "[cyan]What name should we give the [green]nodeset[/green] for your [dark_orange]glidein[/dark_orange]?[/cyan]",
            default=context["project_slug"],
        )



def prompt_site(context: OrderedDict):
    console.print(Panel.fit("=== Data Facility Information ==="))
    data_facility = Prompt.ask(
        "[cyan]At what [green]Data Facility[/green] will this workflow run?[/cyan]",
        choices=["S3DF", "IN2P3", "LANCS", "RAL"],
        default="S3DF",
    )
    match data_facility:
        case "S3DF":
            prompt_s3df(context)
        case "IN2P3":
            prompt_in2p3(context)
        case "LANCS":
            prompt_lancs(context)
        case "RAL":
            prompt_ral(context)


def prompt_s3df(context: OrderedDict):
    site_manifest: OrderedDict = context["_manifests"]["facility"]
    console.print(Panel.fit("=== S3DF Information ==="))

    site_manifest["compute_site"] = "s3df"

    # Capture site-specific auto-provisioning details
    if context["_manifests"]["wms"]["auto_provision"]:

        site_manifest["provisioned_platform"] = "s3df"
        site_manifest["provisioned_queue"] = Prompt.ask(
            "[cyan]What compute queue should BPS Provisioning use?[/cyan]",
            choices=["milano", "roma"],
            default="milano",
        )
        site_manifest["provisioned_account_group"] = Prompt.ask(
            "[cyan]What accounting group should BPS Provisioning use?[/cyan]",
            choices=["rubin:developers", "rubin:production"],
            default="rubin:developers",
        )


# Additonal facility-specific prompts TBD
def prompt_in2p3(context: OrderedDict): ...


def prompt_lancs(context: OrderedDict): ...


def prompt_ral(context: OrderedDict): ...
