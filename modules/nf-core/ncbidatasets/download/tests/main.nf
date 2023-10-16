nextflow_process {

    name "Test Process NCBIDATASETS_DOWNLOAD"
    script "modules/nf-core/ncbidatasets/download/ncbidatasets_download_draft.nf"
    process "NCBIDATASETS_DOWNLOAD"
    autoSort false
    tag "module"


    test("Download genome") {
        tag "genome_single"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """

                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "GCF_000146045.2", command: "genome accession"],
                    ""
                )
                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert process.out.zip.get(0).get(1) ==~ ".*/${meta.id}_ncbi_dataset.zip" },
                { assert process.out.genome.get(0).get(1) ==~ ".*/${meta.id}_.*genomic.fna.gz" },
                { assert process.out.protein.size() == 0 },
                { assert process.out.rna.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
                { assert process.out.cds.size() == 0 },
                { assert process.out.utr_5p.size() == 0 },
                { assert process.out.utr_3p.size() == 0 },
                { assert process.out.gene.size() == 0 },
            )
        }

    }

    test("Download genome with all --include options") {
        tag "genome_single"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"

            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "GCF_000146045.2", command: "genome accession"],
                    "--include genome,rna,cds,gff3,gtf,gbff"
                )

                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert process.out.zip.get(0).get(1) ==~ ".*/${meta.id}_ncbi_dataset.zip" },
                { assert process.out.genome.get(0).get(1) ==~ ".*/${meta.id}_.*genomic.fna.gz" },
                { assert process.out.rna.size() == 1 },
                { assert process.out.rna.get(0).get(1) ==~ ".*/rna.fna.gz" },
                { assert process.out.gff.size() == 1 },
                { assert process.out.gff.get(0).get(1) ==~ ".*/genomic.gff.gz" },
                { assert process.out.gtf.size() == 1 },
                { assert process.out.gtf.get(0).get(1) ==~ ".*/genomic.gtf.gz" },
                { assert process.out.gbff.size() == 1 },
                { assert process.out.gbff.get(0).get(1) ==~ ".*/genomic.gbff.gz" },
                { assert process.out.cds.size() == 1 },
                { assert process.out.cds.get(0).get(1) ==~ ".*/cds.fna.gz" },
                // No protein!
                { assert process.out.protein.size() == 0 },
                { assert process.out.utr_5p.size() == 0 },
                { assert process.out.utr_3p.size() == 0 },
                { assert process.out.gene.size() == 0 },

            )
        }

    }


    test("Download: catch unsupported command") {
        tag "genome_single"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "GCF_009866885.1", command: "genome gene-id"],
                    ""
                )
                """
            }
        }

        then { assert process.failed }
    }


    test("Download genomes from taxon") {
        tag "genome_multiple"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """

                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "3025863", command: "genome taxon"],
                    ""
                )
                """
            }
        }

        then {
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert process.out.zip.get(0).get(1) ==~ ".*/${meta.id}_ncbi_dataset.zip" },
                { assert process.out.genome.size() == 0 },
                { assert process.out.cds.size() == 0 },
                { assert process.out.protein.size() == 0 },
                { assert process.out.gene.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
                { assert process.out.utr_5p.size() == 0 },
                { assert process.out.utr_3p.size() == 0 },

            )
        }

    }

    test("Download gene (NM, NR, NP, XM, XR, XP and YP accessions)") {
        tag "gene"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "NP_000483.3", command: "gene accession"],
                    ""
                )
                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here
            def protein_file = path(process.out.protein.get(0).get(1)).getFileName()
            def rna_file = path(process.out.rna.get(0).get(1)).getFileName()
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/${meta.id}_ncbi_dataset.zip").exists() },
                { assert process.out.protein.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/protein.faa.gz").exists() },
                { assert process.out.rna.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/rna.fna.gz").exists() },

                // gene.fna is not present in NM, NR, NP, XM, XR, XP and YP accessions
                { assert process.out.gene.size() == 0 },
                { assert process.out.genome.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
            )
        }

    }
    test("Download gene with all --include options") {
        tag "gene"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "NP_000483.3", command: "gene accession"],
                    "--include gene,rna,protein,cds,5p-utr,3p-utr"
                )
                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here

            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/${meta.id}_ncbi_dataset.zip").exists() },
                { assert process.out.gene.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/gene.fna.gz").exists() },
                { assert process.out.rna.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/rna.fna.gz").exists() },
                { assert process.out.cds.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/cds.fna.gz").exists() },
                { assert process.out.utr_5p.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/5p_utr.fna.gz").exists() },
                { assert process.out.utr_3p.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/3p_utr.fna.gz").exists() },

                { assert process.out.genome.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
            )
        }

    }

    test("Download gene taxon") {
        tag "gene"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "plasmodium falciparum", command: "gene taxon"],
                    ""
                )
                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here
            def meta = process.out.zip.get(0).get(0)
            def prefix = "${meta.id.replaceAll(' ', '_')}"

            assertAll(
                { assert process.success },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/${prefix}_ncbi_dataset.zip").exists() },

                { assert process.out.protein.size() == 0 },
                { assert process.out.rna.size() == 0 },
                { assert process.out.gene.size() == 0 },
                { assert process.out.genome.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
            )
        }
    }

    test("Download virus") {
        tag "virus"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "NC_045512.2", command: "virus genome accession"],
                    ""
                )
                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/${meta.id}_ncbi_dataset.zip").exists() },
                { assert process.out.genome.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/genomic.fna.gz").exists() },

                { assert process.out.cds.size() == 0 },
                { assert process.out.protein.size() == 0 },
                { assert process.out.gene.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
                { assert process.out.utr_5p.size() == 0 },
                { assert process.out.utr_3p.size() == 0 },
            )
        }
    }

    test("Download virus with all --include options") {
        tag "virus"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "NC_045512.2", command: "virus genome accession"],
                    "--include genome,cds,protein"
                )
                """
            }
        }

        then {
            // assert that the genomic.fna.gz file is present. Name can vary, so needs a bit of workaround here
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/${meta.id}_ncbi_dataset.zip").exists() },
                { assert process.out.genome.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/genomic.fna.gz").exists() },
                { assert process.out.protein.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/protein.faa.gz").exists() },
                { assert process.out.cds.size() == 1 },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/cds.fna.gz").exists() },

                { assert process.out.rna.size() == 0 },
                { assert process.out.gene.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
                { assert process.out.utr_5p.size() == 0 },
                { assert process.out.utr_3p.size() == 0 },


            )
        }
    }

    test("Download virus taxon") {
        tag "virus"

        when {
            params {
                // define parameters here. Example:
                // outdir = "tests/results"
                outdir = "$outputDir"


            }
            process {
                """
                // define inputs of the process here. Example:
                // input[0] = file("test-file.txt")
                input[0] = tuple(
                    [id: "sars-cov-2", command: "virus genome taxon"],
                    "--host cat"
                )
                """
            }
        }

        then {
            def meta = process.out.zip.get(0).get(0)

            assertAll(
                { assert process.success },
                { assert new File("${outputDir}/external_assemblies/${meta.id}/ncbidatasetscli/${meta.id}_ncbi_dataset.zip").exists() },

                { assert process.out.genome.size() == 0 },
                { assert process.out.protein.size() == 0 },
                { assert process.out.cds.size() == 0 },
                { assert process.out.rna.size() == 0 },
                { assert process.out.gene.size() == 0 },
                { assert process.out.gff.size() == 0 },
                { assert process.out.gtf.size() == 0 },
                { assert process.out.gbff.size() == 0 },
                { assert process.out.utr_5p.size() == 0 },
                { assert process.out.utr_3p.size() == 0 },


            )
        }
    }

}

