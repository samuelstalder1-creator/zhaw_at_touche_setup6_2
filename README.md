# setup6_2 Code Submission

This directory is a self-contained TIRA code submission for the
`advertisement-in-retrieval-augmented-generation-2026` task. The container
entrypoint is `/predict.py`. At runtime it loads the published classifier
`sambus211/zhaw_at_touche_setup6_2`, initializes the backbone from
`FacebookAI/roberta-base`, overlays the fine-tuned checkpoint weights, reads
the TIRA input dataset, and writes `predictions.jsonl` in the format expected
by the shared task.

## Submission Package Contents

- `predict.py`: runtime inference entrypoint used by TIRA
- `Dockerfile`: image definition used by `tira-cli code-submission`
- `requirements.txt`: Python dependencies installed into the container
- `.dockerignore`: excludes local caches and outputs from the image context
- `README.md`: submission specification and operator notes

The package does not need local training code. The Docker build preloads both
the published fine-tuned checkpoint and the base `FacebookAI/roberta-base`
weights so the final TIRA runtime can stay offline.

## Runtime Contract

TIRA executes the submission with:

```bash
/predict.py
```

Supported inputs:

- `inputDataset`: mounted TIRA input directory
- `outputDir`: mounted TIRA output directory
- `--dataset`: TIRA dataset id, local directory, or local JSONL file
- `--input-directory`: explicit local or mounted input directory
- `--output-directory`: explicit output directory
- `--output`: explicit output file path

If the input is a directory, `predict.py` automatically discovers the most
likely response file by scanning for JSONL files whose rows contain at least
`id`, `query`, and `response`.

## Input Specification

Each input row must be a JSON object with at least these fields:

- `id`: unique row identifier
- `query`: user query string
- `response`: generated answer to classify

Additional fields are ignored by this setup.

The runtime prompt format for this setup is:

```text
Query: <query>
Response: <response>
Answer:
```

This matches the repository's `setup6` query-plus-response classifier family.

## Output Specification

The submission writes:

```text
predictions.jsonl
```

Default TIRA location:

```text
$outputDir/predictions.jsonl
```

Each output row is a JSON object with exactly these fields:

```json
{"id":"7O2H5WQK-3656-2FVX","label":1,"tag":"zhawAtToucheSetup62"}
```

## Model and Inference Defaults

- Model: `sambus211/zhaw_at_touche_setup6_2`
- Base model: `FacebookAI/roberta-base`
- Architecture: `RobertaForSequenceClassification`
- Default batch size: `16`
- Default max length: `512`
- Default threshold: `0.5`
- Default device selection: `cuda`, then `mps`, then `cpu`

Override values if needed:

```bash
./predict.py \
  --dataset ../zhaw_at_touche/data/task \
  --output ./out/predictions.jsonl \
  --model-name sambus211/zhaw_at_touche_setup6_2 \
  --base-model-name FacebookAI/roberta-base \
  --batch-size 16 \
  --max-length 512 \
  --threshold 0.5 \
  --device cpu
```

## Local Verification

Run on a local directory or JSONL file:

```bash
./predict.py \
  --dataset ../zhaw_at_touche/data/task \
  --output ./out/predictions.jsonl
```

The TIRA-style environment variables also work:

```bash
inputDataset=../zhaw_at_touche/data/task outputDir=./out ./predict.py
```

## Validate The Docker Submission

Authenticate and verify the local TIRA client:

```bash
tira-cli login --token <YOUR_TIRA_TOKEN>
tira-cli verify-installation --task advertisement-in-retrieval-augmented-generation-2026
```

If you use Docker Desktop with the containerd image store enabled, TIRA may
reject uploaded images even though the local build and push succeed. In that
case, force Docker v2 manifest output during submission:

```bash
tira-cli code-submission \
  --path . \
  --task advertisement-in-retrieval-augmented-generation-2026 \
  --dataset ads-in-rag-task-1-detection-spot-check-20260422-training \
  --command '/predict.py' \
  --build-args '--output type=docker --provenance=false'
```

If the failure happens before your submission image is built, prepend the
repo-local Docker wrapper so every `docker build` invoked by `tira-cli` gets
the compatibility flags, including the preflight check:

```bash
PATH="${PWD}/tools:${PATH}" tira-cli code-submission \
  --path . \
  --task advertisement-in-retrieval-augmented-generation-2026 \
  --dataset ads-in-rag-task-1-detection-spot-check-20260422-training \
  --command '/predict.py'
```

Dry-run through TIRA:

```bash
tira-cli code-submission \
  --dry-run \
  --path . \
  --task advertisement-in-retrieval-augmented-generation-2026 \
  --dataset ads-in-rag-task-1-detection-spot-check-20260422-training \
  --command '/predict.py'
```

## Submit To TIRA

From this directory:

```bash
tira-cli code-submission \
  --path . \
  --task advertisement-in-retrieval-augmented-generation-2026 \
  --dataset ads-in-rag-task-1-detection-spot-check-20260422-training \
  --command '/predict.py'
```
