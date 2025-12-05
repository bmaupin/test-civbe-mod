#!/usr/bin/env bash

# This contains all the common build steps needed before packaging or installing the mod

mod_name=$(yq -p xml -oy ".Mod.Properties.Name" src/*.modinfo)
mod_version=$(yq -p xml -oy ".Mod.+@version" "src/${mod_name}.modinfo")
mod_name_version="$(echo "${mod_name} (v ${mod_version})")"

echo "Creating smaller leader images ..."
pushd src/Art/ > /dev/null
for filename in $(find . -type f -iname "*_Leader_256.dds" | cut -c 3-); do
    civ_name=$(echo "$filename" | cut -d _ -f 1)
    # We could check first before converting but it's very fast; the slow part of this script is the creating and extraction of the 7z file
    convert "${civ_name}_Leader_256.dds" -resize 128x128 "${civ_name}_Leader_128.dds"
    convert "${civ_name}_Leader_256.dds" -resize 80x80 "${civ_name}_Leader_80.dds"
    convert "${civ_name}_Leader_256.dds" -resize 64x64 "${civ_name}_Leader_64.dds"
done
popd > /dev/null

echo "Updating mod file checksums ..."
pushd src > /dev/null
# Override IFS (internal field separator) in order to handle files with spaces in name
original_IFS="$IFS"
IFS=$'\n'
for filename in $(find . -type f | cut -c 3-); do
    new_md5sum=$(md5sum "$filename" | awk '{print $1}')
    old_md5sum=$(grep "$filename" "${mod_name}.modinfo" | head -n 1 | awk '{print $2}' | cut -c 6- | rev | cut -c 2- | rev)
    if [[ -n $old_md5sum ]]; then
        sed -i "s@${old_md5sum}\(.*${filename}\)@${new_md5sum}\1@" "${mod_name}.modinfo"
    fi
done
IFS="$original_IFS"
popd > /dev/null

echo "Preparing temporary build directory ..."
temp_dir=$(mktemp -d -p $(pwd))
cp -ar src/. "${temp_dir}"
pushd "${temp_dir}" > /dev/null
mv "${mod_name}.modinfo" "${mod_name_version}.modinfo"
# Lower-case filenames in the .modinfo file so the entry will match after we lower-case
# the filename in the file system. This is required for Linux Steam workshop compatibility.
sed -i '/<File/s|>\(.*\)<|\L&|' "${mod_name_version}.modinfo"
sed -i '/<UpdateDatabase>/s|>\(.*\)<|\L&|' "${mod_name_version}.modinfo"
sed -i '/<EntryPoint/s|file="\([^"]*\)"|file="\L\1"|' "${mod_name_version}.modinfo"
# Lower-case all file names for cross-platform compatibility, particularly Linux (https://stackoverflow.com/a/152741)
find . -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
popd > /dev/null
