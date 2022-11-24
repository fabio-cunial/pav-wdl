version 1.0

task align_ref {
  input {
    File pav_conf
    File pav_asm
    String sample
    String threads
    String mem_gb
  }
  String docker_dir = "/assemblybased"
  String work_dir = "/cromwell_root/assemblybased"
  command <<<
    set -euxo pipefail
    cd ~{docker_dir}
    source activate lr-pav
    mkdir -p ~{work_dir}
    cd ~{work_dir}
    cp -r ~{docker_dir}/pav .
    
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tree
    snakemake -s pav/Snakefile --cores ~{threads} data/ref/ref.fa.gz data/ref/ref.fa.gz.fai
    tar zcvf align_ref_~{sample}.tgz data/ref/ref.fa.gz data/ref/ref.fa.gz.fai
  >>>
  output {
    Array[File] snakemake_logs = glob(work_dir + "/.snakemake/log/*.snakemake.log")
    File refGz = work_dir + "/align_ref_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "fcunial/assemblybased"
  }
}

task align_get_tig_fa_hap {
  input {
    File pav_conf
    File pav_asm
    String sample
    String hap
    String threads
    String mem_gb
  }
  String docker_dir = "/assemblybased"
  String work_dir = "/cromwell_root/assemblybased"
  command <<<
    set -euxo pipefail
    cd ~{docker_dir}
    source activate lr-pav
    mkdir -p ~{work_dir}
    cd ~{work_dir}
    cp -r ~{docker_dir}/pav .
    
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tree
    snakemake -s pav/Snakefile --cores ~{threads} temp/~{sample}/align/contigs_~{hap}.fa.gz temp/~{sample}/align/contigs_~{hap}.fa.gz.fai
    tar zcvf align_get_tig_fa_~{hap}_~{sample}.tgz temp/~{sample}/align/contigs_~{hap}.fa.gz temp/~{sample}/align/contigs_~{hap}.fa.gz.fai
  >>>
  output {
    Array[File] snakemake_logs = glob(work_dir + "/.snakemake/log/*.snakemake.log")
    File asmGz = work_dir + "/align_get_tig_fa_~{hap}_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "fcunial/assemblybased"
  }
}

task align_ref_anno_n_gap {
  input {
    File pav_conf
    File pav_asm
    File ref_gz
    String sample
    String threads
    String mem_gb
  }
  String docker_dir = "/assemblybased"
  String work_dir = "/cromwell_root/assemblybased"
  command <<<
    set -euxo pipefail
    cd ~{docker_dir}
    source activate lr-pav
    mkdir -p ~{work_dir}
    cd ~{work_dir}
    cp -r ~{docker_dir}/pav .
  
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{ref_gz}
    tree
    snakemake -s pav/Snakefile --cores ~{threads} data/ref/n_gap.bed.gz
    tar zcvf align_ref_anno_n_gap_~{sample}.tgz data/ref/n_gap.bed.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(work_dir + "/.snakemake/log/*.snakemake.log")
    File gaps = work_dir + "/align_ref_anno_n_gap_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "fcunial/assemblybased"
  }
}

task align_map_hap {
  input {
    File pav_conf
    File pav_asm
    String hap
    String sample
    File asmGz
    File refGz
    String threads
    String mem_gb
  }
  String docker_dir = "/assemblybased"
  String work_dir = "/cromwell_root/assemblybased"
  command <<<
    set -euxo pipefail
    cd ~{docker_dir}
    source activate lr-pav
    mkdir -p ~{work_dir}
    cd ~{work_dir}
    cp -r ~{docker_dir}/pav .
    
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{asmGz}
    tar zxvf ~{refGz}
    tree
    snakemake -s pav/Snakefile --cores ~{threads} temp/~{sample}/align/pre-cut/aligned_tig_~{hap}.sam.gz
    tar czvf align_map_~{hap}_~{sample}.tgz temp/~{sample}/align/pre-cut/aligned_tig_~{hap}.sam.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(work_dir + "/.snakemake/log/*.snakemake.log")
    File samGz = work_dir + "/align_map_~{hap}_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "fcunial/assemblybased"
  }
}

task align_get_read_bed_hap {
  input {
    File pav_conf
    File pav_asm
    File refGz
    File tigFa
    String sample
    File samGz
    String hap
    String threads
    String mem_gb
  }
  String docker_dir = "/assemblybased"
  String work_dir = "/cromwell_root/assemblybased"
  command <<<
    set -euxo pipefail
    cd ~{docker_dir}
    source activate lr-pav
    mkdir -p ~{work_dir}
    cd ~{work_dir}
    cp -r ~{docker_dir}/pav .
  
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{refGz}
    tar zxvf ~{samGz}
    tar zxvf ~{tigFa}
    tree
    snakemake -s pav/Snakefile --cores ~{threads} results/~{sample}/align/pre-cut/aligned_tig_~{hap}.bed.gz
    tar czvf align_get_read_bed_~{hap}_~{sample}.tgz results/~{sample}/align/pre-cut/aligned_tig_~{hap}.bed.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(work_dir + "/.snakemake/log/*.snakemake.log")
    File bedGz = work_dir + "/align_get_read_bed_~{hap}_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "fcunial/assemblybased"
  }
}

task align_cut_tig_overlap_hap {
  input {
    File pav_conf
    File pav_asm
    File asmGz
    String hap
    File bedGz
    String threads
    String mem_gb
    String sample
  }
  String docker_dir = "/assemblybased"
  String work_dir = "/cromwell_root/assemblybased"
  command <<<
    set -euxo pipefail
    cd ~{docker_dir}
    source activate lr-pav
    mkdir -p ~{work_dir}
    cd ~{work_dir}
    cp -r ~{docker_dir}/pav .
  
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{asmGz}
    tar zxvf ~{bedGz}
    tree
    snakemake -s pav/Snakefile --cores ~{threads} results/~{sample}/align/aligned_tig_~{hap}.bed.gz
    tar czvf align_cut_tig_overlap_~{hap}_~{sample}.tgz results/~{sample}/align/aligned_tig_~{hap}.bed.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(work_dir + "/.snakemake/log/*.snakemake.log")
    File trimBed = work_dir + "/align_cut_tig_overlap_~{hap}_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "fcunial/assemblybased"
  }
}