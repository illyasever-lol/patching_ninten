set -e

# 这里演示一些使用 hactool 解压各项内容的示例
# 更多的内容，请查阅 hactool 项目说明

cd "$(dirname "$0")"

rm -rf temp
mkdir -p temp/data

base_nsp="0000000000000000.nsp"
base_titlekey="00000000000000000000000000000000"
base_outdir="temp/base"
update_nsp="0000000000000000.nsp"
update_titlekey="00000000000000000000000000000000"
update_outdir="temp/update"

# 解压 nsp
hactool -t pfs0 ${base_nsp} --outdir ${base_outdir}
hactool -t pfs0 ${update_nsp} --outdir ${update_outdir}

# 解压主程序 nca
   # 解压出最新的 exefs
hactool -k prod.keys --titlekey=${update_titlekey} --exefsdir=temp/data/exefs \
   --basenca ${base_outdir}/00000000000000000000000000000000.nca \
   ${update_outdir}/00000000000000000000000000000000.nca
   # 直接解压 base nsp 中的 romfs
hactool -k prod.keys --titlekey=${base_titlekey}  --romfsdir=temp/data/romfs \
   ${base_outdir}/00000000000000000000000000000000.nca

# 解压 control nca
hactool -k prod.keys --titlekey=${update_titlekey} --romfsdir=temp/data/control \
   ${update_outdir}/00000000000000000000000000000000.nca

# 解压 legal nca
hactool -k prod.keys --titlekey=${update_titlekey} --romfsdir=temp/data/legal \
   ${update_outdir}/00000000000000000000000000000000.nca

# 解压 doc nca
hactool -k prod.keys --titlekey=${base_titlekey} --romfsdir=temp/data/doc \
   ${base_outdir}/00000000000000000000000000000000.nca

