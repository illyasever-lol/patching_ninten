set -e
shopt -s expand_aliases
cd "$(dirname "$0")"

# 这个脚本对应如下情况的打包
# temp/data
# ├── control
# ├── doc
# ├── exefs
# ├── legal
# └── romfs

# 导出的临时文件目录
outdir="temp/app"
# 导出的游戏/应用ID，保持与原本应用的baseid相同
titleid="0000000000000000"
rm -rf ${outdir}/*.nca

alias base_hacpack="hacpack --type nca --titleid ${titleid} -k prod.keys -o ${outdir} --backupdir temp/hacbpack_backup"

# 1. 打包主程序 nca
program_nca=`base_hacpack --ncatype program --exefsdir temp/data/exefs --romfsdir temp/data/romfs  | grep "NCA: ${outdir}" | awk -F '/' '{print $NF}'`
echo program_nca: ${program_nca}

# 2. 打包control nca
control_nca=`base_hacpack --ncatype control --romfsdir temp/data/control | grep "NCA: ${outdir}" | awk -F '/' '{print $NF}'`
echo control_nca: ${control_nca}

# 3. 打包 legal info nca
legal_nca=`base_hacpack --ncatype manual --romfsdir temp/data/legal | grep "NCA: ${outdir}" | awk -F '/' '{print $NF}'`
echo legal_nca: ${legal_nca}

# 4. 打包 doc nca
doc_nca=`base_hacpack --ncatype manual --romfsdir temp/data/doc | grep "NCA: ${outdir}" | awk -F '/' '{print $NF}'`
echo doc_nca: ${doc_nca}

# 4. 打包meta data nca
base_hacpack --ncatype meta --titletype=application \
    --programnca=${outdir}/${program_nca} \
    --controlnca=${outdir}/${control_nca} \
    --legalnca=${outdir}/${legal_nca} \
    --htmldocnca=${outdir}/${doc_nca}

# 5. 打包成 nsp
base_hacpack --type nsp -o `pwd` --ncadir ${outdir}