

PS1="$"
basedir=`pwd`
echo "Rebuilding Forked projects.... "

pause() {
    if [ "$1" != "" ]; then
        echo -n -e "$1"
    fi
    SAVEDSTTY=`stty -g`
    stty -echo
    stty raw
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    echo ""
    stty $SAVEDSTTY
}

function applyPatch {
    what=$1
    target=$2
    branch=$3
    cd "$basedir/$what"
    git fetch
    git branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d  "$basedir/$target" ]; then
        git clone "$what" "$target"
    fi
    cd "$basedir/$target"
    echo "Resetting $target to $what..."
    git remote add -f upstream ../$what >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git fetch upstream >/dev/null 2>&1
    pause
    git reset --hard upstream/upstream
    rm -f ./Spigot-API/.git/index.lock
    echo "  Applying patches to $target..."
    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${what}-Patches/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

applyPatch Bukkit Spigot-API HEAD && applyPatch CraftBukkit Spigot-Server patched
applyPatch Spigot-API PaperSpigot-API HEAD && applyPatch Spigot-Server PaperSpigot-Server HEAD
applyPatch PaperSpigot-Server FlamePaper-Server HEAD && applyPatch PaperSpigot-API FlamePaper-API HEAD
