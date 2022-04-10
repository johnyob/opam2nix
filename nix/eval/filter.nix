{ lib }:
{ envLib }:

let
  filterScopeEval =
    let self = { allowMissing ? false }: {
      # bool -> bool
      bool = value: value;

      # string -> string
      string = value: value;

      # env -> any
      ident = envLib.eval {
        onMissing =
          if allowMissing then
            _: _: null
          else
            envLib.defaultOnMissing;
      };

      # any -> any -> bool
      equal = lhs: rhs: lhs == rhs;

      # any -> any -> bool
      notEqual = lhs: rhs: lhs != rhs;

      # any -> any -> bool
      greaterEqual = lhs: rhs: lhs >= rhs;

      # any -> any -> bool
      greaterThan = lhs: rhs: lhs > rhs;

      # any -> any -> bool
      lowerEqual = lhs: rhs: lhs <= rhs;

      # any -> any -> bool
      lowerThan = lhs: rhs: lhs < rhs;

      # bool -> bool -> bool
      and = lhs: rhs: lhs && rhs;

      # bool -> bool -> bool
      or = lhs: rhs: lhs || rhs;

      # bool -> bool
      not = x: !x;

      # filter -> bool
      def = filter: filter (self { allowMissing = true; }) != null;

      # ?
      undef = abort "Bad use of filterScopeEval.undef!";
    }; in self;

  # filter -> any
  evalFilter = filter: filter (filterScopeEval { });

  filterScopeShow = {
    bool = builtins.toJSON;

    string = builtins.toJSON;

    ident = f:
      let value = envLib.eval { } f; in
      {

        local = { name, ... }: "${value} (${name})";

        package = { packageName, name, ... }: "${value} (${packageName}:${name})";

        combine = values:
          lib.foldl'
            (lhs: rhs: "${lhs} & ${rhs}")
            (lib.head values)
            (lib.tail values);
      };

    equal = lhs: rhs: "${lhs} == ${rhs}";

    notEqual = lhs: rhs: "${lhs} != ${rhs}";

    greaterEqual = lhs: rhs: "${lhs} >= ${rhs}";

    greaterThan = lhs: rhs: "${lhs} > ${rhs}";

    lowerEqual = lhs: rhs: "${lhs} <= ${rhs}";

    lowerThan = lhs: rhs: "${lhs} < ${rhs}";

    and = lhs: rhs: "${lhs} && ${rhs}";

    or = lhs: rhs: "${lhs} || ${rhs}";

    def = filter: "?(${showFilter filter})";

    undef = abort "filterScopeShow.undef";
  };

  showFilter = filter: filter filterScopeShow;

in
{
  eval = evalFilter;
  show = showFilter;
}
