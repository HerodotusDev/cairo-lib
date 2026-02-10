import argparse
import subprocess
import re
import os
import pandas as pd

def bench(name, force):
    try:
        with open(os.path.join("results", name), "w" if force else "x") as f:
            test_out = subprocess.check_output(["scarb", "test"], cwd="..")
            results = []
            for line in test_out.decode("utf-8").split("\n"):
                m = re.match(r"^test ([a-zA-Z0-9_:]+) ... ok \(gas usage est\.: (\d+)\)$", line)
                if m:
                    results.append(f"{m.group(1)} {m.group(2)}")
            f.write("\n".join(results))
    except FileExistsError:
        print(f"Bench {name} already exists. If you want to overwrite it, pass the --force flag.")


def results():
    bench_names = []
    for file in os.listdir("results"):
        if file.startswith("."):
            continue
        bench_names.append(file)
    
    results = {}
    test_names = set()
    for bench in bench_names:
        with open(os.path.join("results", bench), "r") as f:
            for line in f.read().split("\n"):
                test_name, gas = line.split(" ")
                test_names.add(test_name)
                if not test_name in results:
                    results[test_name] = {}
                results[test_name][bench] = gas
    test_names = list(test_names)
    test_names.sort()
    
    table = [[None for _ in bench_names] for _ in test_names]
    for i, test in enumerate(test_names):
        for j, bench in enumerate(bench_names):
            try:
                table[i][j] = results[test][bench]
            except KeyError:
                pass
    df = pd.DataFrame(table, index=test_names, columns=bench_names)
    df.to_excel("results.xlsx")
    


def main():
    parser = argparse.ArgumentParser(description="Process some commands.")
    
    # Create a subparser object
    subparsers = parser.add_subparsers(dest="command", help='sub-command help')

    # Create the parser for the "bench" command
    parser_bench = subparsers.add_parser('bench', help='Run a benchmark')
    parser_bench.add_argument('benchmark_name', type=str, help='The name of the benchmark to run')
    parser_bench.add_argument('--force', action='store_true', help='Overwrite the benchmark if it already exists')

    # Create the parser for the "results" command
    parser_results = subparsers.add_parser('results', help='Show results')

    # Parse the arguments
    args = parser.parse_args()

    # Decide what to do based on the command
    if args.command == 'bench':
        bench(args.benchmark_name, args.force)
    elif args.command == 'results':
        results()
    else:
        parser.print_help()


if __name__ == '__main__':
    main()