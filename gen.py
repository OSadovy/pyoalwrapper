"""Some quick&dirty utils to generate cython wrappers from declarations."""

from jinja2 import Template

props_template ="""
    property {{name}}:
        def __get__(self): return self.{{instance_field}}.{{orig_name}}
        def __set__(self, {{orig_type}} v): self.{{instance_field}}.{{orig_name}} = v
"""

func_template = """
def {{name}}({{args}}):
    {% if return_type != 'void' %}return {% endif %}{{orig_name}}({{arg_names}})
"""
func_template = """
def {{name}}({{args}}):
    if gpDevice is not NULL:
        {% if return_type != 'void' %}return {% endif %}gpDevice.{{orig_name}}({{arg_names}})
"""

method_template = """
    def {{name}}(self{% if args %}, {{args}}{% endif %}):
        {% if return_type != 'void' %}return {% endif %}{{orig_name}}(self.{{instance_field}}{% if arg_names %}, {{arg_names}}{% endif %})
"""

props_get_set_template ="""
    property {{name}}:
        def __get__(self): return (<{{type}}>self.{{instance_field}}).Get{{orig_name}}()
        def __set__(self, {{orig_type}} v): (<{{type}}>self.{{instance_field}}).Set{{orig_name}}(v)
"""

efx_inlines = """inline EFXEAXREVERBPROPERTIES get_{{macro}}() { EFXEAXREVERBPROPERTIES r = {{macro}}; return r; }"""

def list_contains(list, sublist):
    for i in xrange(len(list)-len(sublist)+1):
        if sublist == list[i:i+len(sublist)]:
            return i
    return -1

def split_camelcase(n, known_abbrevs=None):
    l = []
    word = ''
    for c in n:
        if c.isupper() or not (c.isalpha() or c.isdigit()):
            if word:
                l.append(word)
            word = c
        else:
            word += c
    if word:
        l.append(word)
    if known_abbrevs is not None:
        for abbrev in known_abbrevs:
            i = list_contains(l, list(abbrev))
            if i == -1:
                continue
            l[i:i+len(abbrev)] = [abbrev]
    return filter(lambda i: i != '_', l)

def pythonize_name(n, unwanted_prefixes):
    l = split_camelcase(n, known_abbrews)
    while l[0] in unwanted_prefixes:
        del l[0]
    return '_'.join(i.lower() for i in l)

def parse_var_def(s):
    l = []
    for line in s.split('\n'):
        line = line.strip(' \t;').replace('\t', ' ')
        if not line:
            continue
        words = line.split()
        if words[0] == 'const':
            del words[0]
        l.append(words)
    return l

def parse_func_def(s):
    l = []
    for line in s.split('\n'):
        line = line.strip(' \t;').replace('\t', ' ')
        if not line:
            continue
        before, after = line.split('(', 1)
        args, after = after.rsplit(')', 1)
        if after:
            raise ValueError(after)
        w = before.split()
        if w[0] == 'const':
            del w[0]
        w.append(parse_var_def('\n'.join(args.split(','))))
        l.append(w)
    return l

inp = """
    float flDensity;
    float flDiffusion;
    float flGain;
    float flGainHF;
    float flGainLF;
    float flDecayTime;
    float flDecayHFRatio;
    float flDecayLFRatio;
    float flReflectionsGain;
    float flReflectionsDelay;
    float flReflectionsPan[3];
    float flLateReverbGain;
    float flLateReverbDelay;
    float flLateReverbPan[3];
    float flEchoTime;
    float flEchoDepth;
    float flModulationTime;
    float flModulationDepth;
    float flAirAbsorptionGainHF;
    float flHFReference;
    float flLFReference;
    float flRoomRolloffFactor;
    int   iDecayHFLimit;
"""
known_abbrews = ('EFX', 'OAL', 'LF', 'HF')

def gen_properties(inpp):
    t = Template(props_template)
    for (orig_type, orig_name) in parse_var_def(inp):
        ctx = {
            'name': pythonize_name(orig_name, ('ml', 'ms', 'mb')),
            'orig_name': orig_name,
            'orig_type': orig_type,
            'instance_field': 'params',
        }
        print t.render(ctx)

def gen_set_get_properties(inpp):
    t = Template(props_get_set_template)
    for (orig_type, orig_name) in parse_var_def(inp):
        name = orig_name[2:]
        ctx = {
            'name': pythonize_name(name, []),
            'orig_name': name,
            'type': 'cOAL_Effect_Reverb*',
            'orig_type': orig_type,
            'instance_field': 'inst',
        }
        print t.render(ctx)

def gen_funcs(inp):
    t = Template(func_template)
    for return_type, orig_name, args in parse_func_def(inp):
        for i, arg in enumerate(args):
            arg[-1] = pythonize_name(arg[-1][2:], [])
        ctx = {
            'name': pythonize_name(orig_name, ('OAL', 'Info')),
            'orig_name': orig_name,
            'args': ', '.join(' '.join(a) for a in args),
            'arg_names': ', '.join(a[1] for a in args),
            'return_type': return_type,
        }
        print t.render(ctx)

def gen_methods(inp):
    t = Template(method_template)
    for return_type, orig_name, args in parse_func_def(inp):
        if args[0][-1].startswith('alSource'):
            del args[0]
        for i, arg in enumerate(args):
            arg[-1] = pythonize_name(arg[-1][2:], [])
        ctx = {
            'name': pythonize_name(orig_name, ('OAL', 'Source')),
            'orig_name': orig_name,
            'args': ', '.join(' '.join(a) for a in args),
            'arg_names': ', '.join(a[-1] for a in args),
            'return_type': return_type,
            'instance_field': 'handle',
        }
        print t.render(ctx)

def gen_efx_inlines(inp):
    t = Template(efx_inlines)
    for m in inp.split('\n'):
        m = m.strip()
        if not m:
            continue
        print t.render({
            'macro': m
        })
def gen_set_efx(inpp):
    for (orig_type, orig_name) in parse_var_def(inp):
        name = orig_name[2:]
        print "        (<cOAL_Effect_Reverb*>self.inst).Set%s(props.%s)" % (name, orig_name)

if __name__ == '__main__':
    gen_set_efx(inp)
